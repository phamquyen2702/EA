#include <Trade/Trade.mqh>

CTrade trade;

input int k_period = 5;
input int d_period = 3;
input int slowing = 3;
input double volumn = 0.01;
input double breakOut = 100;

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
//check breakout keylv zigzag
bool checkBreakOut(double point, string trend) {
	MqlRates PriceInfo[];
	ArraySetAsSeries(PriceInfo,true);
	int copied = CopyRates(_Symbol,PERIOD_H1,0,100,PriceInfo); 
	double close = PriceInfo[1].close;
	double open= PriceInfo[1].open;
	double high= PriceInfo[1].high;
	double low= PriceInfo[1].low;
	string model = modelCandle(high,low,open,close);

	if (trend == "up"){
		if( close > ( point + breakOut)){
			if (model == "blue_mazu" || model == "blue_pinbar_bot"){
				return true;
			}
			
		}
	}

	if (trend == "down"){
		if( close < point - breakOut){
			if (model == "red_mazu" || model == "red_pinbar_top"){
				return true;
			}
		}
	}
	 return false;

}

// model candle
string modelCandle(double high, double low, double open, double close) {
	string model;
	double bodyCandle;
	double sizeCandle;
	
	if(open > close){
		bodyCandle = open - close;
		sizeCandle = high - low;
		double sizeLowClose = close - low;
		double sizeHighOpen = high - open;
		if (bodyCandle >= 2 * sizeCandle / 3 ){
			return "red_mazu";	//break		
		} else if(bodyCandle < 2 * sizeCandle / 3 && sizeLowClose >= sizeCandle / 3){
			return "red_pinbar_bot";
		} else if(bodyCandle < 2 * sizeCandle / 3 && sizeHighOpen >= sizeCandle / 3){
			return "red_pinbar_top"; //break
			return "red_pinbar_top"; //break
		} else {
			return "red_spinningtopaaaaaaa";
		}
	} else {
		bodyCandle = close - open;
		sizeCandle = high - low;
		double sizeLowOpen = open - low;
		double sizeHighClose = high - close;
		if (bodyCandle >= 2 * sizeCandle / 3 ){
			return "blue_mazu";	//break		
		} else if(bodyCandle < 2 * sizeCandle / 3 && sizeLowOpen >= sizeCandle / 3){
			return "blue_pinbar_bot";//break
		} else if(bodyCandle < 2 * sizeCandle / 3 && sizeHighClose >= sizeCandle / 3){
			return "blue_pinbar_top";
			return "blue_pinbar_top";
			return "blue_pinbar_top";
		} else {
			return "blue_spinningtop";
			return "blue_spinningtop";
		}
	}
	return model;;
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
   
   bool check = checkBreakOut(85.224,"up");
   Print("Status breakout", check);
   Print("Status breakout", check);
   Print("Status breakout", check);
 }
 

