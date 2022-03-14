#include <Trade/Trade.mqh>

CTrade trade;

input int k_period = 5;
input int d_period = 3;
input int slowing = 3;
input double volumn = 0.01;

// Condition Stochastic
string StochasticCondition(){
   string signal = "sideway";
   
   double KArray[];
   double DArray[];
   
   ArraySetAsSeries(KArray,true);
   ArraySetAsSeries(DArray,true);
   
   //init Stochastic
   int initStochastic = iStochastic(_Symbol,_Period,k_period,d_period,slowing,MODE_SMA,STO_LOWHIGH);
   CopyBuffer(initStochastic,0,0,3,KArray);
   CopyBuffer(initStochastic,1,0,3,DArray);
   
   double kValue0 = KArray[0];
   double dValue0 = DArray[0];
   
   double kValue1 = KArray[1];
   double dValue1 = DArray[1];
   
   if (kValue0 < 20 && dValue0 < 20 && kValue1 < 20 && dValue1 < 20 && kValue0 > dValue0 && kValue1 < dValue1){
     signal = "buy";
   }
   
   if (kValue0 > 80 && dValue0 > 80 && kValue1 > 80 && dValue1 > 80 && kValue0 < dValue0 && kValue1 > dValue1){
     signal = "sell";
   }
   
   return signal;
}
// create Sl 
double createSL(double zValue1, double zValue2, double zValue3, double zValue4){
   double sl;
   
   if (zValue1 > zValue2) {
       double range = zValue1 - zValue2;
       if (range <= 200){
         sl = range / 2;
       } else {
         sl = range / 3;
       }
       
   } else {
       double range = zValue2 - zValue1;
        if (range <= 200){
         sl = range / 2;
       } else {
         sl = range / 3;
       }
   }
   return sl;
}

//create Tp
double createTP(double zValue1, double zValue2, double zValue3, double zValue4){
   return zValue1;
}

void OnTick(){
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   double SL = 200;
   double TP = 600;
   
   string signal = StochasticCondition();
   if (PositionSelect(_Symbol) == false) {
      if (signal == "sell") {
         trade.Sell(volumn,NULL,Bid,(Bid + SL*_Point),(Bid - TP*_Point),NULL);
         trade.Sell(volumn,NULL,Bid,(Bid + SL*_Point),(Bid - 1.1*SL*_Point),NULL);
      }
      if (signal == "buy") {
         trade.Buy(volumn,_Symbol,Ask,(Ask - SL*_Point),(Ask + TP*_Point),NULL);
         trade.Buy(volumn,_Symbol,Ask,(Ask - SL*_Point),(Ask + 1.1*SL*_Point),NULL);
      }
   }
 }
