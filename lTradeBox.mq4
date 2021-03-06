// Copyright (C) 2015
// Markus Zancolò <markus.zancolo@gmx.net>
//                
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

//+------------------------------------------------------------------+
//|                                                    lTradeBox.mq4 |
//|Diese Library beinhaltet einige häufig verwendete und nützliche   |
//| Funktionen,die das Coden von EAs und Scripts vereinfachen sollen.|
//|Für Fragen und Anregungen: Es gibt ein Supporttopic:              |
//|  http://www.tom-next.com/community/MQL-Library-mit-Standardfunktionen-t32132.html
//|
//|Auf diese Lib gibt es keinerlei Garantie, wer sie verwendet ist   |
//| selbst für Schäden und Verluste verantwortlich.                  |
//|                                                                  |
//|Mit freundlicher Unterstützung von | powered by                   |
//| www.tom-next.com and www.tradescout.at                           |
//+------------------------------------------------------------------+

#define VERSION_NUMBER 1.23

//====================================================================
//
//Change Log:
//#1.23 20.01.2017
//  fixed compileerror in new mql4
//#1.22 07.06.2015
//  added supportAndResistance Method
//#1.21 31.01.2012
//  added global parameter to if sl and tp should not be send with OrderSend but Modified after sending
//#1.19 24.09.2011
//  added arrow_color to tbSendOrder, tbModifyOrder and tbCloseOrder
//#1.18  20.06.2010
//  small changes in tbSetTP and tbSetStop to not ignore 0
//#1.17  01.04.2010
// added setTP
//#1.16  21.03.2010
// added querys for safety sake to setStop
//#1.15  24.02.2010
// added setStop for hidden stop and manual stop-watch ;)
//#1.14  19.02.2010
// changed error-prints to alerts
//#1.13  17.02.2010
// added normalizeDouble to all prices (in real trading not necessary but needed
//  to handle the "foreign history backtest-bug"
//#1.12 2009.06.10
//debugged tbModifyOrder
//#1.11 2009.06.10
//added access functions to MM Module
//#1.10 2009.05.30
//added parameter trail to tbModifyOrder
//#1.09 2009.05.01
//added glob_stoplevel
//debug Trail module
//added tbArrayMeanPart
//#1.08 2009.04.15
//added tbLinRegSlopeConstX in Statistics
//added tbArrayMean
//#1.071 2009.04.11
//debug normalizeTakeProfit
//added debuginfo in tbSendOrder
//#1.07 2009.03.22
//added trailing stop module
//added moneymanagement module
//#1.06 2009.02.22
//modified tbModifyOrder
//added logging "module"
//added tbGetDayOfWeek
//#1.05 2009.02.08
//debugged normalization-functions for stoploss and takeprofit
//added Information to tbModifyOrder 
//#1.04 2009.02.01:
//added TBCloseOrder
//added NormalizeDouble into the normalization-functions
//added Level 4 Information to tbSendOrder
//#1.03 2009.01.26:
//added the global variable information_level and TBSetInformationLevel to set the variable
//added Parameter max_retries to TBOrderSend with defaultValue -1 for MaxTrials
//added TBGetVersionNumber()
//added Information on Level 4 in normalizePrice
//added Information on Level 3 in TBOrderSend
//changed normalizing the prices to "not trusting MathMod"
//#1.02:
//debugged normalizePrice (MathMin/MathMax)
//changed filename and License
//#1.01:
//added helper functions:
// normalizePrice,normalizeStopLoss, normalizeTakeProfit and integrated
// them into TBOrderSend and TBOrderModify
//added init with VersionNumber and Comment.
//added check for Contract Expiration in TBOrderSend and TBOrderModify
//#1.0:
//~included some useful functions, debugged the lotsize calculations (MT Bug!)
//
// TODO:
// - docu the functions
// - function if new day is started
// - trail backup and recovery
//====================================================================
//existing functions:
//                       
// void init()
// void deinit()
//
//                     ~ACCESS FUNCTIONS~
// void tbSetInformationLevel(int val)
// double tbGetVersionNumber()
// void tbOverrideStoplevel(double new_level)
// void tbNoStopOnSend(boolean value)
//
//                     ~TRADING FUNCTIONS~
// #internal:
// double normalizePrice(double price, int cmd, string symbol)
// double normalizeStopLoss(double price,double stoploss, int cmd, string symbol)
// double normalizeTakeProfit(double price,double takeprofit, int cmd, string symbol)
//
// #external:
// int tbSendOrder(string symbol,int cmd,double volume,double price,int slippage,double stoploss,double takeprofit, string comment,int magic, datetime expiration,int max_retries = -1,color arrow_color = CLR_NONE)
// int tbModifyOrder(int ticket,double price,double stoploss,double takeprofit, datetime expiration, int max_retries= -1,bool trail = false,color arrow_color = CLR_NONE)
// int tbCloseOrder(int ticket,double lots,int slipage,int max_retries = -1,color arrow_color = CLR_NONE)
// void tbSetStop(int iOrderTicket,double dStopLoss,bool bHidden,int iSlippage,int iMaxRetries= -1)
// void tbSetTP(int iOrderTicket,double dTakeProfit,bool bHidden,int iSlippage,int iMaxRetries = -1)
//
//                     ~ TRAILING STOP~    global var prefix 'trail_'
// void tbTrailInit(double af_start,double af_max,double af_inc)
// void tbTrailReset(double new_ep,int direction)
// void tbTrailUpdateEP(double new_ep)
// int tbTrailUpdateOrder(int ticket)
// double tbTrailNewStop(double curStop)
// void tbTrailGetVars(double& ep, int& direction, double& af)
// void tbTrailSetVars(double ep, int direction, double af)
//
//                      ~MONEY MANAGEMENT~  global var prefix 'mm_'
// #internal:
// int mmGetIDFromMode(string mode)
//
// #external:
// void tbMM1ParamInit(string mode,double max_lots,double init_value)
// void tbMM3ParamInit(string mode,double max_lots,double init_value1,double init_value2,double init_value3)
// double tbMMGetLotSize(double risk,bool update)
// double tbMMgetCurrentRiskAbsolut()
// void tbMMsetCurrentRiskAbsolut(double risk)

//                     ~ORDER INFORMATIONS~
// bool tbIsTodayOrdersOpen(string symbol= "",int type=-1, int magic=-1) 
//
//                ~STATISTICS/MATH~
// double tbLinRegSlopeConstX(double y_vals[])
// double tbArrayMean(double array[])
// double tbArrayMeanPart(double array[],int start,int length)
//
//                        ~LOGGING~   global var prefix 'log_'
// void tbSetLogFileName(string filename)
// void tbLogTrades(bool override,int time_mode=0,int magicnumber=0,string symbol="")
// void tbLogTodaysTrades(int magicnumber)
// void tbLogWeeklyTrades(int magicnumber)
// void tbLogMonthlyTrades(int magicnumber)
// void tbLogAllTrades(int magicnumber)
//
//              ~USEFULL STUFF~
// string tbGetDayOfWeek(datetime date)
// double tbPoint();
//
//       ~OTHER STUFF~
//int tbSRFillSupportResistance(double& array[][SR_ARRAY_IDX_COUNT],int type, int startIndex = 0, int maxBars= -1)
//void tbSRSetParams(int clusterSize,int maxPostForWeight= 500, int maxBars=500, int period= 0, bool printMarker= false)

//
//====================================================================

#property link "http://www.tom-next.com/community/MQL-Library-mit-Standardfunktionen-t32132.html"

#property library
  
#include <stderror.mqh>

#import "stdlib.ex4"
  string ErrorDescription(int error_code);
#import

#define MAX_TRIALS 5
#define PAUSE_ON_BUSY 3000
#define PAUSE_ON_TOO_FREQUENT 10000

//defines the level of information to be printed, default is 2
//-1 ... all information
// 0 ... totally no information, 
// 1 ... only Alerts,  
// 2 ... basic information on performed operations
// 3 ... advanced information on performed operations
// 4 ... detailed output (for debug)

int information_level= 2; 
double glob_stoplevel_=0;
bool email_active_ = false;
bool trade_no_sl_on_send_= false;

//--------------- init and deinit -----------------------------------

void init()
{
  Print("Initialising TradeBox Version ",VERSION_NUMBER," happy trading");
  Comment("powered by TradeBox ",VERSION_NUMBER);
}

void deinit()
{
  Comment("");
}

//================== "Access Functions" ============================

void setEmailStatus(bool status)
{
  email_active_= status;
}

void tbSetInformationLevel(int val)
{
  information_level= val;
  if(val > 0)
    Print("TB",VERSION_NUMBER," set information level to:", val);
  if(val < 0)
    Print("TB",VERSION_NUMBER," set information level to max");
  if(val == 0)
    Print("TB",VERSION_NUMBER," is set totally silent");
}

double tbGetVersionNumber()
{
  return(VERSION_NUMBER);
}

void tbOverrideStoplevel(double new_level)
{
  glob_stoplevel_= new_level;
}

void tbNoStopOnSend(bool value){
   trade_no_sl_on_send_= value;
}
//====================================================================
//                     TRADING FUNCTIONS
//====================================================================

//lib-internal helper-functions
// normalize the entryprice
double normalizePrice(double price, int cmd, string symbol)
{
  double stoplevel= MathMax(glob_stoplevel_,MarketInfo(symbol,MODE_STOPLEVEL));
  double ticksize= MarketInfo(symbol,MODE_TICKSIZE);
  double bid= MarketInfo(symbol,MODE_BID);
  double ask= MarketInfo(symbol,MODE_ASK);
  double point= MarketInfo(symbol,MODE_POINT);
  double newprice= price;
  int temp_price;
  if(cmd == OP_BUY || cmd == OP_BUYLIMIT || cmd == OP_SELLSTOP)
  {
  //version if not trusting MathMod:
    temp_price=NormalizeDouble(price/ticksize,0);
    newprice= NormalizeDouble(temp_price*ticksize,MarketInfo(symbol,MODE_DIGITS));
  //version if trustin MathMod:  
    //newprice= price - MathMod(price,ticksize);
    if(cmd == OP_BUY)
      newprice= ask;
    if(cmd == OP_BUYLIMIT)
      newprice= MathMin(newprice,ask - stoplevel*point);
    if(cmd == OP_SELLSTOP)
      newprice= MathMin(newprice,bid - stoplevel*point);
  }
      
  if(cmd == OP_SELL || cmd == OP_SELLLIMIT || cmd == OP_BUYSTOP)
  {
    //version if not trusting MathMod:
    temp_price=NormalizeDouble(price/ticksize,0);
    newprice= NormalizeDouble(temp_price*ticksize,MarketInfo(symbol,MODE_DIGITS));
  //version if trustin MathMod:  
    //newprice= price - MathMod(price,ticksize) + ticksize;
    if(cmd == OP_SELL)
      newprice= bid;
    if(cmd == OP_SELLLIMIT)
      newprice= MathMax(newprice,bid + stoplevel*point);
    if(cmd == OP_BUYSTOP)
      newprice= MathMax(newprice,ask + stoplevel*point);
  }
  if((information_level < 0 || information_level >= 4))
    Print("TB",VERSION_NUMBER," current quote: ",bid,"/",ask," stoplevel:",stoplevel," Point:",point);
  
  newprice= NormalizeDouble(newprice,MarketInfo(symbol,MODE_DIGITS));
  return(newprice);
}

//normalize the stoploss given the entryprice
double normalizeStopLoss(double price,double stoploss, int cmd, string symbol)
{
  double stoplevel= MathMax(glob_stoplevel_,MarketInfo(symbol,MODE_STOPLEVEL)); 
  double ticksize= MarketInfo(symbol,MODE_TICKSIZE);
  double spread= MarketInfo(symbol,MODE_SPREAD);
  double point= MarketInfo(symbol,MODE_POINT);
  double newstoploss= stoploss;
  int temp_price;
  
  if( cmd == OP_BUY || cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP)
  {
    if(stoploss != 0)
    {
    //version if not trusting MathMod:
      temp_price=NormalizeDouble(stoploss/ticksize,0);
      newstoploss= NormalizeDouble(temp_price*ticksize,MarketInfo(symbol,MODE_DIGITS));
    //version if trustin MathMod:  
      //newstoploss= stoploss - MathMod(stoploss,ticksize);
      if(cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP)
        newstoploss= MathMin(newstoploss,price - (stoplevel+spread)*point);
      if(cmd == OP_BUY)
        newstoploss= MathMin(newstoploss,MarketInfo(symbol,MODE_BID) - stoplevel*point);
    }
  }
  
  if( cmd == OP_SELL || cmd == OP_SELLLIMIT || cmd == OP_SELLSTOP)
  {
    if(stoploss != 0)
    {
    //version if not trusting MathMod:
      temp_price=NormalizeDouble(stoploss/ticksize,0);
      newstoploss= NormalizeDouble(temp_price*ticksize,MarketInfo(symbol,MODE_DIGITS));
    //version if trustin MathMod:  
      //newstoploss= stoploss - MathMod(stoploss,ticksize) + ticksize;
      if(cmd == OP_SELLLIMIT || cmd == OP_SELLSTOP)
        newstoploss= MathMax(newstoploss,price + (stoplevel+spread)*point);
      if(cmd == OP_SELL)
        newstoploss= MathMax(newstoploss,MarketInfo(symbol,MODE_ASK) + stoplevel*point);
    }
  }
  if((information_level < 0 || information_level >= 4) && stoploss != newstoploss)
    Print("TB",VERSION_NUMBER," modified stoploss to: ",newstoploss);
  
  newstoploss= NormalizeDouble(newstoploss,MarketInfo(symbol,MODE_DIGITS));
  return(newstoploss);
}

// normalize the takeprofit given the entryprice
double normalizeTakeProfit(double price,double takeprofit, int cmd, string symbol)
{
  double stoplevel= MathMax(glob_stoplevel_,MarketInfo(symbol,MODE_STOPLEVEL)); 
  double ticksize= MarketInfo(symbol,MODE_TICKSIZE);
  double spread= MarketInfo(symbol,MODE_SPREAD);
  double point= MarketInfo(symbol,MODE_POINT);
  double newtakeprofit= takeprofit;
  int temp_price;
  if( cmd == OP_BUY || cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP)
  {
    if(takeprofit != 0)
    {
    //version if not trusting MathMod:
      temp_price=NormalizeDouble(takeprofit/ticksize,0);
      newtakeprofit= NormalizeDouble(temp_price*ticksize,MarketInfo(symbol,MODE_DIGITS));
    //version if trustin MathMod:  
      //newtakeprofit= takeprofit - MathMod(takeprofit,ticksize) + ticksize;
      if(cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP)
        newtakeprofit= MathMax(newtakeprofit,price + (stoplevel+spread)*point);
      if(cmd == OP_BUY)
        newtakeprofit= MathMax(newtakeprofit,MarketInfo(symbol,MODE_BID) + stoplevel*point);
    }
  }
  
  if( cmd == OP_SELL || cmd == OP_SELLLIMIT || cmd == OP_SELLSTOP)
  {
    if(takeprofit != 0)
    {
    //version if not trusting MathMod:
      temp_price=NormalizeDouble(takeprofit/ticksize,0);
      newtakeprofit= NormalizeDouble(temp_price*ticksize,MarketInfo(symbol,MODE_DIGITS));
    //version if trustin MathMod:  
      //newtakeprofit= takeprofit - MathMod(takeprofit,ticksize);
      if(cmd == OP_SELLLIMIT || cmd == OP_SELLSTOP)
        newtakeprofit= MathMin(newtakeprofit,price - (stoplevel+spread)*point);
      if(cmd == OP_SELL)
        newtakeprofit= MathMin(newtakeprofit,MarketInfo(symbol,MODE_ASK) - stoplevel*point);
    }
  }
  if((information_level < 0 || information_level >= 4) && takeprofit != newtakeprofit)
    Print("TB",VERSION_NUMBER," modified takeprofit to: ",newtakeprofit);
  
  newtakeprofit= NormalizeDouble(newtakeprofit,MarketInfo(symbol,MODE_DIGITS));
  return(newtakeprofit);
}
//+------------------------------------------------------------------+
//| send Order, including price normalization                        |
//|   tries to send a order with the given parameters, therefore     |
//|   "normalizes" the price, stoploss and takeprofit to avoid       |
//|   INVALID_STOP Errors, also normalize the lotsize and cut it     |
//|   into [MinlotSize,MaxLotSize]. Therefore no adaption to the     |
//|   prices and lotsize has to be made outside of the function.     |
//|   If OrderSend not suceed it tries severaltimes till it gives up |
//|   If giving up it prints an Alert with the Error Description     |
//| @param symbol: Symbol for the Order                              |
//| @param cmd: Ordercommand See Trade operation enumeration         |
//| @param volume: prefered lotsize (may be changed to valid lotsize)|
//| @param price: prefered price where to open the Order             |
//| @param slippage: allowed slipage                                 |
//| @param stoploss: prefered stoploss for the Order                 |
//| @param takeprofit: prefered takeprofit                           |
//| @param comment: comment for the Order                            |
//| @param magic: magicnumber for the order                          |
//| @param expiration: expiration of the order                       |
//| @param max_retries: maximum number of retries if OrderSend fails |
//| @return ticket if OrderSend succeed, otherwise (-1)*the errorcode|
//+------------------------------------------------------------------+
int tbSendOrder(string symbol,int cmd,double volume,double price,int slippage,double stoploss,double takeprofit, string comment,int magic, datetime expiration,int max_retries = -1,color arrow_color = CLR_NONE)
{
  if(!IsTradeAllowed()) {
    if(information_level != 0)
      Alert("Trading is not allowed at the moment!");
    return(-1);
  }

  int loopcount=0,result,error,vol_in_steps;
  double lot_step= MarketInfo(symbol,MODE_LOTSTEP);
  double minlot= MarketInfo(symbol,MODE_MINLOT);
  double maxlot= MarketInfo(symbol,MODE_MAXLOT);
  int digits= MarketInfo(symbol,MODE_DIGITS);
  datetime exp= MarketInfo(symbol,MODE_EXPIRATION);
  // consinstence checks, normalizing the price
  if(information_level < 0 || information_level >= 4)
    Print("TB",VERSION_NUMBER," got command send: ",comment," cmd:",cmd," in:",symbol," ",volume,"@",price,"sl:",stoploss,"tp:",takeprofit,"magic:",magic,"expir:",TimeToStr(expiration));
  if(information_level == 3)
    Print("TB",VERSION_NUMBER," got command send: ",comment," ", symbol," ",volume,"@",price,"sl:",stoploss,"tp:",takeprofit);
  if(max_retries < 0)
    max_retries= MAX_TRIALS;
    
  price= normalizePrice(price,cmd,symbol);
  stoploss= normalizeStopLoss(price,stoploss,cmd,symbol);
  takeprofit= normalizeTakeProfit(price,takeprofit,cmd,symbol);
  
  //producing a valid lotsize
  vol_in_steps=volume/lot_step; // getting the integer (cut off) value of lotsteps to invest.
  volume= vol_in_steps*lot_step; //now the volume is normalized to full lot steps
  volume= MathMin(maxlot,MathMax(minlot,volume)); // no empty orders, not trading too much ;)
  
  if(expiration < TimeLocal())
    expiration= 0;
  if(exp > 0 && expiration > exp)
  {
    if(information_level != 0)
      Alert("TB",VERSION_NUMBER,": Order would last longer than the contract!");
    return(-1);
  }
  if(information_level < 0 || information_level >= 2)
    Print("TB",VERSION_NUMBER," Sending: ",comment," ", symbol," ",volume,"@",DoubleToStr(price,digits),"sl:",DoubleToStr(stoploss,digits),"tp:",DoubleToStr(takeprofit,digits)," till:",TimeToStr(expiration));
  result= mySend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,comment,magic,expiration,arrow_color,max_retries);
  while(result == -1)
  {
    error=GetLastError();
    switch(error)
    {
      case ERR_SERVER_BUSY:
      case ERR_BROKER_BUSY:
      case ERR_TRADE_CONTEXT_BUSY:
        Sleep(PAUSE_ON_BUSY);
        break;
      case ERR_TOO_FREQUENT_REQUESTS:
        Sleep(PAUSE_ON_TOO_FREQUENT);
        break;
      case ERR_NOT_ENOUGH_MONEY:
        if(information_level != 0)
          Alert("TB",VERSION_NUMBER,": We are broke!");
        return(-error);
      case ERR_TRADE_TOO_MANY_ORDERS:
        if(information_level != 0)
          Alert("TB",VERSION_NUMBER,": Too many open trades!");
        return(-error);
    }
    loopcount++;
    if(loopcount > max_retries)
    {
      if(information_level != 0)
        Alert("TB",VERSION_NUMBER,": Give up trying after ",loopcount, " tries to send Order:",comment," ",volume,"@",price,"sl:",stoploss,"tp:",takeprofit," error was:",ErrorDescription(error));
      return(-error);
    }
    RefreshRates();
    price= normalizePrice(price,cmd,symbol);
    stoploss= normalizeStopLoss(price,stoploss,cmd,symbol);
    takeprofit= normalizeTakeProfit(price,takeprofit,cmd,symbol);
    if(information_level < 0 || information_level >= 3)
      Print("TB",VERSION_NUMBER," retry#",loopcount," ",comment," ", symbol," with ",volume,"@",price,"sl:",stoploss,"tp:",takeprofit);
    if(information_level < 0 || information_level >= 2)
      Print("TB",VERSION_NUMBER," Error sending order: ",error," ",ErrorDescription(error));
    result= mySend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,comment,magic,expiration,arrow_color,max_retries);
  }
  if(information_level < 0 || information_level >= 3)
    Print("TB",VERSION_NUMBER," suceed sending with ",loopcount," retries, OrderTicket: ",result);
  return(result);
} 

int mySend( string symbol, int cmd, double volume, double price, int slippage, double stoploss, 
            double takeprofit, string comment, int magic, datetime expiration, color arrow_color,int max_retries){
   if(!trade_no_sl_on_send_ || (stoploss == 0 && takeprofit == 0))
     return(OrderSend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,comment,magic,expiration,arrow_color));
   
   int result;
   if(trade_no_sl_on_send_) {
      result= OrderSend(symbol,cmd,volume,price,slippage,0,0,comment,magic,expiration,arrow_color);
      if(result == -1)
         return(-1);
      bool gotIt= OrderSelect(result,SELECT_BY_TICKET);
      if(!gotIt) {
         Print("TB",VERSION_NUMBER,": Error selecting Order after Send");
         return(-1);
      }
      int error= 0;
      int loopcount=0;
      while(!OrderModify(result,OrderOpenPrice(),stoploss,takeprofit,OrderExpiration()))
      {
        error=GetLastError();
        switch(error)
        {
          case ERR_SERVER_BUSY:
          case ERR_BROKER_BUSY:
          case ERR_TRADE_CONTEXT_BUSY:
            Sleep(PAUSE_ON_BUSY);
            break;
          case ERR_TOO_FREQUENT_REQUESTS:
            Sleep(PAUSE_ON_TOO_FREQUENT);
            break;
          case ERR_INVALID_TICKET:
            if(information_level != 0)
              Print("TB",VERSION_NUMBER,": Order was closed while trying to modify it(",error," ",ErrorDescription(error),")");
            return(-error);
        
        }
        loopcount++;
        if(loopcount > max_retries)
        {
          if(information_level != 0)
            Alert("TB",VERSION_NUMBER,": Give up trying after ",loopcount, " couldnt set SL and TP on Order :",OrderLots(),"@",OrderOpenPrice()," sl:",stoploss,"tp:",takeprofit," error was:",ErrorDescription(error));
          return(-error);
        }
        RefreshRates();
        
        stoploss= normalizeStopLoss(OrderOpenPrice(),stoploss,OrderType(),OrderSymbol());
        takeprofit= normalizeTakeProfit(OrderOpenPrice(),takeprofit,OrderType(),OrderSymbol());
      }
      return(result);
   } 
   return(-1); //never happens but compiler warns
}

//+------------------------------------------------------------------+
//| modify Order inkl. normalization                      |
//+------------------------------------------------------------------+
int tbModifyOrder(int ticket,double price,double stoploss,double takeprofit, datetime expiration,int max_retries= -1,bool trail = false,color arrow_color= CLR_NONE)
{
  
  if(!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
    return(-1);
  double ticksize= MarketInfo(OrderSymbol(),MODE_TICKSIZE);
  datetime exp= MarketInfo(OrderSymbol(),MODE_EXPIRATION);
  
  if(information_level < 0 || information_level >= 3)
    Print("TB",VERSION_NUMBER," got command: modify ",OrderComment()," ", OrderSymbol()," to ",OrderLots(),"@",price,"sl:",stoploss,"tp:",takeprofit);
  if(max_retries < 0)
    max_retries= MAX_TRIALS;
  
  if(OrderType() == OP_BUY || OrderType() == OP_SELL)
  {
    price= OrderOpenPrice();
    expiration= OrderExpiration();
  }
  else
    price= normalizePrice(price,OrderType(),OrderSymbol());
  
  
  // check expiration for validy
  if(expiration < TimeLocal())
    expiration= OrderExpiration();
    
  if(exp > 0 && expiration > exp)
  {
    if(information_level != 0)
      Alert("TB",VERSION_NUMBER,": Order would last longer than the contract!");
    return(-1);
  }
    
  //Normalize stoploss and takeprofit with respect to the stoplevel 
  if(MathAbs(stoploss - OrderStopLoss()) >= ticksize*0.5)
    stoploss= normalizeStopLoss(price,stoploss,OrderType(),OrderSymbol());
  else
    stoploss= OrderStopLoss();
  if(MathAbs(takeprofit - OrderTakeProfit()) >= ticksize*0.5)
    takeprofit= normalizeTakeProfit(price,takeprofit,OrderType(),OrderSymbol());
  else
    takeprofit= OrderTakeProfit();
      
  if(information_level < 0 || information_level >= 4)
      Print("TB",VERSION_NUMBER," transformed command to: ",OrderComment()," ", OrderSymbol()," to ",OrderLots(),"@",price,"sl:",stoploss,"tp:",takeprofit);
     
  // Do the Modify
  if(OrderType() == OP_BUY && trail)
    stoploss= MathMax(stoploss,OrderStopLoss());
  if(OrderType() == OP_SELL && trail)
    stoploss= MathMin(stoploss,OrderStopLoss());
  
  
  if( MathAbs(stoploss - OrderStopLoss())>= ticksize || MathAbs(takeprofit - OrderTakeProfit()) >= ticksize 
      || MathAbs(price - OrderOpenPrice()) >= ticksize || expiration != OrderExpiration())
  {
    if(information_level < 0 || information_level >= 2)
      Print("TB",VERSION_NUMBER," Modifying: ",OrderComment()," ", OrderSymbol()," to ",OrderLots(),"@",price,"sl:",stoploss,"tp:",takeprofit);
    bool result= OrderModify(ticket,price,stoploss,takeprofit,expiration,arrow_color);
    int error= 0;
    int loopcount=0;
    while(!result)
    {
      error=GetLastError();
      switch(error)
      {
        case ERR_SERVER_BUSY:
        case ERR_BROKER_BUSY:
        case ERR_TRADE_CONTEXT_BUSY:
          Sleep(PAUSE_ON_BUSY);
          break;
        case ERR_TOO_FREQUENT_REQUESTS:
          Sleep(PAUSE_ON_TOO_FREQUENT);
          break;
        case ERR_NOT_ENOUGH_MONEY:
        if(information_level != 0)
          Alert("TB",VERSION_NUMBER,": We are broke!");
          return(-error);
        case ERR_TRADE_TOO_MANY_ORDERS:
          if(information_level != 0)
            Alert("TB",VERSION_NUMBER,": Too many open trades!");
          return(-error);
        case ERR_INVALID_TICKET:
          if(information_level != 0)
            Print("TB",VERSION_NUMBER,": Order was closed while trying to modify it(",error," ",ErrorDescription(error),")");
          return(-error);
        
      }
      loopcount++;
      if(loopcount > max_retries)
      {
        if(information_level != 0)
          Alert("TB",VERSION_NUMBER,": Give up trying after ",loopcount, " tries to modify Order:",OrderComment()," ", OrderSymbol()," with ",OrderLots(),"@",price,"sl:",stoploss,"tp:",takeprofit," error was:",ErrorDescription(error));
        return(-error);
      }
      RefreshRates();
      if(OrderType() != OP_BUY && OrderType() != OP_SELL)
        price= normalizePrice(price,OrderType(),OrderSymbol());
    
      if(MathAbs(stoploss - OrderStopLoss()) >= ticksize)
        stoploss= normalizeStopLoss(price,stoploss,OrderType(),OrderSymbol());
      if(MathAbs(takeprofit - OrderTakeProfit()) >= ticksize)
        takeprofit= normalizeTakeProfit(price,takeprofit,OrderType(),OrderSymbol());
      if(OrderType() == OP_BUY && trail)
        stoploss= MathMax(stoploss,OrderStopLoss());
      if(OrderType() == OP_SELL && trail)
        stoploss= MathMin(stoploss,OrderStopLoss());
  
      if( MathAbs(stoploss - OrderStopLoss())< ticksize && MathAbs(takeprofit - OrderTakeProfit()) < ticksize 
        && MathAbs(price - OrderOpenPrice()) < ticksize && expiration == OrderExpiration())
        return(0);
  
      if(information_level < 0 || information_level >= 3)
        Print("TB",VERSION_NUMBER," retry#",loopcount," ",OrderComment()," ", OrderSymbol()," with ",OrderLots(),"@",price,"sl:",stoploss,"tp:",takeprofit);
      if(information_level < 0 || information_level >= 2)
        Print("TB",VERSION_NUMBER," Error modifing order: ",error," ",ErrorDescription(error));
      result= OrderModify(ticket,price,stoploss,takeprofit,expiration,arrow_color);
    }
  
    if(result)
      return(1);
    else
      return(-GetLastError());
  }
  else
    return(0);
}

//+------------------------------------------------------------------+
//| close Order inkl. Retry delete if pending                      |
//+------------------------------------------------------------------+

int tbCloseOrder(int ticket,double lots,int slipage,int max_retries = -1,color arrow_color=CLR_NONE)
{
  if(!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
    return(-1);
  bool closed= false;
  int error= 0,loopcount=0;
  int my_digits= MarketInfo(OrderSymbol(),MODE_DIGITS);
  
  if(max_retries < 0)
    max_retries= MAX_TRIALS;
  if(information_level < 0 || information_level >= 2)
    Print("TB",VERSION_NUMBER," Closing: ",ticket," ",OrderComment()," in ",OrderSymbol()," ",lots,"@ quotes:",MarketInfo(OrderSymbol(),MODE_BID),"/",MarketInfo(OrderSymbol(),MODE_ASK));
  
  double price=0;
  if(OrderType() == OP_BUY)
    closed= OrderClose(ticket,lots,NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),my_digits),slipage,arrow_color);
  else if(OrderType() == OP_SELL)
    closed= OrderClose(ticket,lots,NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),my_digits),slipage,arrow_color);
  else //pending order
    closed= OrderDelete(ticket,arrow_color);
  
  while(!closed)
  {
    error=GetLastError();
    switch(error)
    {
      case ERR_SERVER_BUSY:
        case ERR_BROKER_BUSY:
        case ERR_TRADE_CONTEXT_BUSY:
          Sleep(PAUSE_ON_BUSY);
          break;
      case ERR_TOO_FREQUENT_REQUESTS:
        Sleep(PAUSE_ON_TOO_FREQUENT);
        break;
      case ERR_INVALID_TICKET:
        if(information_level != 0)
          Print("TB",VERSION_NUMBER,": Order was closed elsewhere while trying to close it(",error," ",ErrorDescription(error),")");
        return(-error);
    }
    loopcount++;
    if(loopcount > max_retries)
    {
      if(information_level != 0)
        Alert("TB",VERSION_NUMBER,": Give up trying after ",loopcount, " tries to close Order:",OrderComment()," ",lots," error was:",ErrorDescription(error));
      return(-error);
    }
      
    if(information_level < 0 || information_level >= 3)
      Print("TB",VERSION_NUMBER," retry#",loopcount," ",OrderComment());
    if(information_level < 0 || information_level >= 2)
      Print("TB",VERSION_NUMBER," Error closing order: ",error," ",ErrorDescription(error));
      
    RefreshRates();
    if(OrderType() == OP_BUY)
      closed= OrderClose(ticket,lots,NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),my_digits),slipage,arrow_color);
    else if(OrderType() == OP_SELL)
      closed= OrderClose(ticket,lots,NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),my_digits),slipage,arrow_color);
    else //pending order
      closed= OrderDelete(ticket,arrow_color);
  }
  if(closed)
    return(1);
  else
    return(-1);
}

//--------------------------------------------------------------------------------------------------

void tbSetStop(int iOrderTicket,double dStopLoss,bool bHidden,int iSlippage,int iMaxRetries = -1) {
  if(!OrderSelect(iOrderTicket,SELECT_BY_TICKET,MODE_TRADES))
    return;
  if(NormalizeDouble(dStopLoss,MarketInfo(Symbol(),MODE_DIGITS)) == 0) {
    tbModifyOrder(OrderTicket(),OrderOpenPrice(),0,OrderTakeProfit(),OrderExpiration(),iMaxRetries,false);
    return; // nothing to do
  }  
  
  double dRealStop=dStopLoss;
  //Sell would be closed at the Ask-Price
  if(OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP) {
    dRealStop += MarketInfo(OrderSymbol(),MODE_SPREAD)*MarketInfo(OrderSymbol(),MODE_POINT);
    
    if(NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK) - dRealStop,MarketInfo(OrderSymbol(),MODE_DIGITS)) >= 0)
      tbCloseOrder(OrderTicket(),OrderLots(),iSlippage,iMaxRetries);
    else if(!bHidden)
      tbModifyOrder(OrderTicket(),OrderOpenPrice(),dRealStop,OrderTakeProfit(),OrderExpiration(),iMaxRetries,false);
  }
  
  if(OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) {
    if(NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID) - dRealStop,MarketInfo(OrderSymbol(),MODE_DIGITS)) <= 0) 
      tbCloseOrder(OrderTicket(),OrderLots(),iSlippage,iMaxRetries);
    else if(!bHidden)
      tbModifyOrder(OrderTicket(),OrderOpenPrice(),dRealStop,OrderTakeProfit(),OrderExpiration(),iMaxRetries,false);
  }

}

//--------------------------------------------------------------------------------------------------

void tbSetTP(int iOrderTicket,double dTakeProfit,bool bHidden,int iSlippage,int iMaxRetries = -1) {
  if(!OrderSelect(iOrderTicket,SELECT_BY_TICKET,MODE_TRADES))
    return;
  if(NormalizeDouble(dTakeProfit,MarketInfo(Symbol(),MODE_DIGITS)) == 0) {
    tbModifyOrder(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),0,OrderExpiration(),iMaxRetries,false);
    return; // nothing to do
  }
  
  double dRealTP=dTakeProfit;
  //Sell would be closed at the Ask-Price
  if(OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP) {
    dRealTP += MarketInfo(OrderSymbol(),MODE_SPREAD)*MarketInfo(OrderSymbol(),MODE_POINT);
    
    if(NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)-dRealTP,MarketInfo(OrderSymbol(),MODE_DIGITS)) <= 0)
      tbCloseOrder(OrderTicket(),OrderLots(),iSlippage,iMaxRetries);
    else if(!bHidden)
      tbModifyOrder(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),dRealTP,OrderExpiration(),iMaxRetries,false);
  }
  
  if(OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) {
    if(NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-dRealTP,MarketInfo(OrderSymbol(),MODE_DIGITS)) >= 0) 
      tbCloseOrder(OrderTicket(),OrderLots(),iSlippage,iMaxRetries);
    else if(!bHidden)
      tbModifyOrder(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),dRealTP,OrderExpiration(),iMaxRetries,false);
  }

}

//====================================================================
//              TRAILING STOP
//====================================================================
// for performing a parabolic trailing stop, the trades extrem point
// is stored in global variable
// init the Trailingstop once (at the init of the EA) with tbTrailInit
// at the beginning of each trade reset the ep and direction with
// tbTrailReset
// during the trade: Update the EP with tbTrailUpdateEP
// this could be done anytime the EP could have changed, if there is
// no ep, nothing happens.
// tbTrailUpdateOrder trails the StopLoss of the given order.
//
// getVars and setVars is only done for backup and recover the internal
// variables.

double trail_trade_extrem_=0;
int trail_direction_=0;
double trail_current_af_=0;
double trail_af_max_=0,trail_af_start_=0,trail_af_inc_=0;

// initialize values for Acceleratiofactor
void tbTrailInit(double af_start,double af_max,double af_inc)
{
  trail_af_start_= af_start;
  trail_af_max_= af_max;
  trail_af_inc_= af_inc;
  trail_current_af_= af_start;
}

// to be called at the beginning of each trade (or trailing period)
void tbTrailReset(double new_ep,int direction)
{
  trail_trade_extrem_=new_ep;
  trail_direction_= direction;
  trail_current_af_= trail_af_start_;
}

// updating the ep, checks if the new_ep is really a ep
void tbTrailUpdateEP(double new_ep)
{
  if((trail_trade_extrem_ - new_ep)*trail_direction_ < 0)
  {
    trail_trade_extrem_= new_ep;
    trail_current_af_ = MathMin(trail_current_af_+trail_af_inc_,trail_af_max_);
  }
}

double tbTrailNewStop(double curStop) {
return curStop + (trail_trade_extrem_ - curStop)*trail_current_af_;
}

// trails the stop for the current order
int tbTrailUpdateOrder(int ticket)
{
  if(!OrderSelect(ticket,SELECT_BY_TICKET))
    return(-1);
  double new_stop= tbTrailNewStop(OrderStopLoss());
  
  if((normalizeStopLoss(OrderOpenPrice(),new_stop,OrderType(),OrderSymbol()) - OrderStopLoss())*trail_direction_ > 0)
    return(tbModifyOrder(OrderTicket(),OrderOpenPrice(),new_stop,OrderTakeProfit(),OrderExpiration(),true));
  else
    return(0);
}

//--- accessfunctions

void tbTrailGetVars(double& ep, int& direction, double& af)
{
  ep= trail_trade_extrem_;
  direction= trail_direction_;
  af= trail_current_af_;
}

double tbTrailGetVarsep()
{
  return(trail_trade_extrem_);
}

double tbTrailGetVarsDirection()
{
  return(trail_direction_);
}

double tbTrailGetVarsaf()
{
  return(trail_current_af_);
}

void tbTrailSetVars(double ep, int direction, double af)
{
  trail_trade_extrem_=ep;
  trail_direction_= direction;
  trail_current_af_= af;
}


//====================================================================
//                     MONEY MANAGEMENT
//====================================================================
// for calculatin the lotsize given the risk of the trade.
// by initializing one have to choose the algorithm to calculate the risk in money
// either fixed percent of the current balance or a fixed amount of money
// or other modes added later on (f.e. percent-based with a threshold)
// depending on the number of parameter one of the different init - functions should be choosen
// (tbMM<x>ParamInit)

string mm_mode_= "FixedPercent";
int mm_mode_id_=0;
double mm_current_risk_absolut_=0;
double mm_param1_=0, mm_param2_=0, mm_param3_=0;
double mm_max_lots_=0;

double tbMMgetCurrentRiskAbsolut()
{
  return(mm_current_risk_absolut_);
}

void tbMMsetCurrentRiskAbsolut(double risk)
{
  mm_current_risk_absolut_= risk;
}

//internal
int mmGetIDFromMode(string mode)
{
  if(mode == "FixedPercent")
    return(1);
  if(mode == "FixedMoney")
    return(2);
  if(mode == "ThresholdPercent")
    return(3);
    
    return(0);//compiler warning
}

//----------------------------------------------------

void tbMM1ParamInit(string mode,double max_lots,double init_value)
{
  mm_mode_= mode;
  mm_mode_id_ = mmGetIDFromMode(mode);
  mm_param1_= init_value;
  mm_max_lots_= max_lots;
  switch(mm_mode_id_)
  {
    case 1: //FixedPercent
      mm_current_risk_absolut_= AccountBalance()*init_value;
      break;
    case 2: //FixedMoney
      mm_current_risk_absolut_= init_value;
      break;
    default:
      if(information_level != 0)
        Alert("TB",VERSION_NUMBER,"_MM: unkown 1 parameter-mode:",mode);
      break;
  }
}

//----------------------------------------------------

void tbMM3ParamInit(string mode,double max_lots,double init_value1,double init_value2,double init_value3)
{
  mm_mode_= mode;
  mm_mode_id_ = mmGetIDFromMode(mode);
  mm_param1_= init_value1;
  mm_param2_= init_value2;
  mm_param3_= init_value3;
  mm_max_lots_= max_lots;
  switch(mm_mode_id_)
  {
    case 3: //"ThresholdPercent"
      // mm_param1 .. lower threshold
      // mm_param2 .. upper threshold
      // mm_param3 .. changing factor 0 < x < 1
      mm_current_risk_absolut_= AccountBalance()*(mm_param1_ + mm_param2_)/2.0;
      break;
    default:
      if(information_level != 0)
        Alert("TB",VERSION_NUMBER,"_MM: unkown 3 parameter-mode:",mode);
      break;
  }   
}
// @param risk: risk in points

double tbMMGetLotSize(double risk,bool update=true)
{
  double lots=1;
  double ticksize= MarketInfo(Symbol(),MODE_TICKSIZE);
  double pointvalue=MarketInfo(Symbol(),MODE_TICKVALUE)/ticksize;
  double lot_step= MarketInfo(Symbol(),MODE_LOTSTEP);
  double minlot= MarketInfo(Symbol(),MODE_MINLOT);
  double maxlot= MarketInfo(Symbol(),MODE_MAXLOT);
  double current_risk_perc=0,temp_absolute=0;
   
  if(mm_max_lots_ > 0)
    maxlot= MathMin(maxlot,mm_max_lots_);
  // update current_risk_absolut
  switch(mm_mode_id_)
  {
    case 1: //FixedPercent
      current_risk_perc= mm_param1_;
      temp_absolute= AccountBalance()*mm_param1_;
      break;
    case 2: //FixedMoney
      temp_absolute= mm_param1_;
      break;
    case 3: // Threshold Percent
      // calc current percent risk
      current_risk_perc= mm_current_risk_absolut_/AccountBalance();
      if(current_risk_perc < mm_param1_ || current_risk_perc > mm_param2_)
        current_risk_perc= current_risk_perc + mm_param3_*((mm_param2_+mm_param1_)/2.0 - current_risk_perc);
      temp_absolute= AccountBalance()*current_risk_perc;
      break;
  }
  if(information_level < 0 || information_level >= 4)
      Print("TB",VERSION_NUMBER,"_MM: got risk: ",risk," thats in Currency: ",risk*pointvalue);
  
  if(information_level < 0 || information_level >= 2)
      Print("TB",VERSION_NUMBER,"_MM: current_risk_absolut: ",mm_current_risk_absolut_," thats ",current_risk_perc*100,"% of Account Balance: ",AccountBalance());
  
  // calc lots from absolut_risk
  lots= temp_absolute/(risk*pointvalue);
  lots= MathFloor(lots/lot_step)*lot_step;
  lots= MathMax(MathMin(lots,maxlot),minlot);
  if(update)
    mm_current_risk_absolut_= temp_absolute;
    
  return(lots);
}
  

//====================================================================
//                     ORDER INFORMATIONS
//====================================================================

//Function to check if an order of the given type and magic number
//was opened today
//@param symbol: if "any": all symbols are watched, "" means current symbol

bool tbIsTodayOrdersOpen(string symbol= "",int type=-1, int magic=-1) // default values only for symbol reasons (cant be used in libs)
{  
  int cnt = OrdersHistoryTotal();
  string internsymbol=Symbol();
  
  if(symbol == "")
    internsymbol= Symbol();
  else
    internsymbol= symbol;
  //check closed orders
  for (int i=cnt-1; i>=0; i--) 
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
    if (internsymbol != "any" && OrderSymbol() != internsymbol) continue;
    if (magic != -1 && OrderMagicNumber() != magic) continue;  
    if (type != -1 && OrderType() != type) continue;
     
    if (TimeDay(OrderOpenTime())==Day()
        && TimeMonth(OrderOpenTime())==Month()
        && TimeYear(OrderOpenTime())==Year()) 
      return(True);
  }
  //if not returned jet, check open orders
  cnt = OrdersTotal();
  for (i=cnt-1; i>=0; i--) 
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    if (internsymbol != "any" && OrderSymbol() != internsymbol) continue;
    if (magic != -1 && OrderMagicNumber() != magic) continue;  
    if (type != -1 && OrderType() != type) continue;
     
    if (TimeDay(OrderOpenTime())==Day()
        && TimeMonth(OrderOpenTime())==Month()
        && TimeYear(OrderOpenTime())==Year()) 
      return(True);
  }
  //no order found:  
  return(False);
}


//====================================================================
//                            STATISTIC/MATH
//====================================================================


//-----------------------------------------

double tbLinRegSlopeConstX(double& y_vals[])
{
  int length= ArraySize(y_vals);
  double x_mean=0,y_mean=0;
  double SSxy=0,SSxx=0;
  int index=0;
  
  for(index=0;index < length;index++)
  {
    y_mean+=y_vals[index];
  }
  y_mean/= length;
  x_mean= length/2; //x in {1,...,length}
  
  for(index=0;index < length;index++)
  {
    SSxy+=(index+1 - x_mean)*(y_vals[index] - y_mean);
    SSxx+=MathPow((index+1 - x_mean),2);
  }
  return(SSxy/SSxx);
}

//--------------------------------------------
double tbArrayMean(double& array[])
{
  int index=0;
  double sum=0;
  for(index=0;index < ArraySize(array);index++)
  {
    if(array[index] != EMPTY_VALUE)
      sum+= array[index];
  }
  if(ArraySize(array) > 0)
    return(sum/ArraySize(array));
  else
    return(0);
}


//--------------------------------------------
double tbArrayMeanPart(double& array[],int start,int length)
{
  int index=0;
  double sum=0;
  if(ArraySize(array) < start+length)
    return(0);
  for(index=0;index < length;index++)
  {
    if(array[start+index] != EMPTY_VALUE)
      sum+= array[start+index];
  }
  if(length > 0)
    return(sum/length);
  else
    return(0);
}

//====================================================================
//======================Logging Functions=============================
//====================================================================

string log_file_name_="logfile";

//--------------------------------------------------------------------
// Init filename for logging
// nameending is always .log
void tbSetLogFileName(string filename)
{
  log_file_name_= filename;
  if(information_level < 0 || information_level >= 3)
    Print("TB",VERSION_NUMBER," set name of logfile to: \'",log_file_name_,".log\'");
}


//--------------------------------------------------------------------
// basic logging function
// special thanks to Krümel
//
// @param override: if append to existing file or override (true means override)
// @param time_mode: timeperiod of to be logged, the closing time counts!
//                   0 ... all trades (default)
//                   1 ... current Month
//                   2 ... current week
//                   3 ... current day
// @param magicnumber: magicnumer to be logged, of 0 all orders will be logged

void tbLogTrades(bool shouldOverride,int time_mode,int magicnumber,string symbol)
{
  int handle=0;
  datetime closetime=0;
  string filename=log_file_name_;
  
  switch(time_mode)
  {
    case 1:
      filename= filename + "_"+DoubleToStr(Year(),0)+"_M"+DoubleToStr(Month(),0);
      closetime= TimeCurrent() - (Seconds() + 60*(Minute() + 60*(Hour() + 24*Day())));
      break;
    case 2:
      int week_of_year= MathCeil((DayOfYear()-DayOfWeek())/7)+1;
      filename= filename + "_"+DoubleToStr(Year(),0)+"_W"+DoubleToStr(week_of_year,0);
      closetime= TimeCurrent() - (Seconds() + 60*(Minute() + 60*(Hour() + 24*DayOfWeek())));
      break;
    case 3:
      filename= filename + "_"+DoubleToStr(Year(),0)+"_"+DoubleToStr(Month(),0)+"_"+DoubleToStr(Day(),0);
      closetime= TimeCurrent() - (Seconds() + 60*(Minute() + 60*Hour()));
      break;
    default:
      filename= filename + "_All";
      break;
  }
  if(symbol != "")
    filename= filename + "_"+symbol;
  if(magicnumber != 0)
    filename= filename + "_magicnr" + DoubleToStr(magicnumber,0);
    
  filename= filename + ".log";
  
  if(shouldOverride)
    handle=FileOpen(filename,FILE_WRITE|FILE_CSV,';');
  else
  {
    handle= FileOpen(filename,FILE_READ|FILE_WRITE|FILE_CSV,';');
    FileSeek(handle,0,SEEK_END);
  }
  if(handle<1)
  {
    if(information_level != 0)
      Alert("TB",VERSION_NUMBER,": Error opening logfile:",filename);
    return;   
  }
  //header
  if(shouldOverride || FileTell(handle) == 0)
  {
    FileWrite(handle,"Ticket","Comment","Lots","Ordertype","OpenTime","OpenPrice","StopLoss","TakeProfit",
                       "CloseTime","ClosePrice","Commission","Swap","Profit");
  }  
  //logging only closed Orders
  for (int i = 0; i < OrdersHistoryTotal(); i++) 
  {
    if(!OrderSelect(i, SELECT_BY_POS,MODE_HISTORY )) {
      continue;
    }
    if((symbol != "" && OrderSymbol() != symbol) ||
       (magicnumber != 0 && OrderMagicNumber() != magicnumber) ||
       (OrderCloseTime() < closetime))
      continue;
    
     FileWrite(handle,OrderTicket(),OrderComment(),OrderLots(),OrderType(),OrderOpenTime(),OrderOpenPrice(),
                      OrderStopLoss(),OrderTakeProfit(),OrderCloseTime(),OrderClosePrice(),OrderCommission(),
                      OrderSwap(),OrderProfit());
  }         
  if(information_level < 0 || information_level >= 3)
    Alert("TB",VERSION_NUMBER,": wrote log to file:",filename);
  FileClose(handle);
}

//--------------------------------------------------------------------------

void tbLogTodaysTrades(int magicnumber)
{
  tbLogTrades(true,3,magicnumber,Symbol());
}

//--------------------------------------------------------------------------

void tbLogWeeklyTrades(int magicnumber)
{
  tbLogTrades(true,2,magicnumber,Symbol());
}

//--------------------------------------------------------------------------

void tbLogMonthlyTrades(int magicnumber)
{
  tbLogTrades(true,1,magicnumber,Symbol());
}

//--------------------------------------------------------------------------

void tbLogAllTrades(int magicnumber)
{
  tbLogTrades(true,0,magicnumber,Symbol());
}

//====================================================================
//                     USEFUL STUFF
//====================================================================

//returns the name of the day given by date

string tbGetDayOfWeek(datetime date)
{
  switch(TimeDayOfWeek(date))
  {
    case 0:
      return("Sunday");
    case 1:
      return("Monday");
    case 2:
      return("Tuesday");
    case 3:
      return("Wednesday");
    case 4:
      return("Thursday");
    case 5:
      return("Friday");
    case 6:
      return("Saturday");
   } 
   
   return("Whats wrong here?");
}

//+------------------------------------------------------------------+
// returns current PointValue but in case of 5-digit broker it returns 0.0001

double tbPoint() {
   if (Digits==5 || Digits ==3 || Digits == 1) 
     return(Point*10);
   else 
     return(Point);
}

//+------------------------------------------------------------------+

int tbGetPeriodWithOffset(int offset) {
   int period= Period();
   if(offset > 0) {
      while(offset-- > 0) {
         period= tbGetNextHigherPeriod(period);
      }
   } else if(offset < 0) {
      while(offset++ < 0) {
         period= tbGetNextLowerPeriod(period);
      }
   }
   return(period);
}

int tbGetNextLowerPeriod(int period) {
  switch(period) {
  case PERIOD_M15:
      return(PERIOD_M5);
  case PERIOD_M30:
      return(PERIOD_M15);
  case PERIOD_H1:
       return(PERIOD_M30);
  case PERIOD_H4:
      return(PERIOD_H1);
  case PERIOD_D1:
      return(PERIOD_H4);
  case PERIOD_W1:
      return(PERIOD_D1);
  case PERIOD_MN1:
      return(PERIOD_W1);
  default:
      return(PERIOD_M1);
  }
}

int tbGetNextHigherPeriod(int period) {
 switch(period) {
  case PERIOD_M1:
       return(PERIOD_M5);
  case PERIOD_M5:
      return(PERIOD_M15);
  case PERIOD_M15:
      return(PERIOD_M30);
  case PERIOD_M30:
      return(PERIOD_H1);
  case PERIOD_H1:
       return(PERIOD_H4);
  case PERIOD_H4:
      return(PERIOD_D1);
  case PERIOD_D1:
      return(PERIOD_W1);
  default:
      return(PERIOD_MN1);
  }
}


//====================================================================
//                     OTHER STUFF
//====================================================================


//+------------------------------------------------------------------+
// fills the array with Support and/or resistance levels, each level with a weight




#define SR_RESISTANCE 1
#define SR_SUPPORT 2

#define SR_ARRAY_WEIGHT_IDX 0
#define SR_ARRAY_PRICE_IDX 1
#define SR_ARRAY_REAL_PRICE_IDX 2
#define SR_ARRAY_IDX_COUNT 3

//number of bars a Extreme is valid before it gets weight-reduced
int sr_weight_max_post= 500;
//max number of bars for validy in either direction
int sr_max_bars= 500;

int sr_cluster_size= 5;

int sr_period= 0;

bool sr_print_marker= false;

int sr_weight_type= 1;

int sr_maxViolations= 0;

double sr_violationBuffer= 1;

bool sr_dynamic_clusters = false;


double tbSRWeight(int barsBack, int validPreBars, int validPostBars,int stillGoingValueFactor) {
   double firstFaktor= 12;
   int maxRange= 10;
   if(sr_max_bars > 500) {
      firstFaktor= 10;
      maxRange= 20;
   }
   int validy=  MathMin(validPreBars,validPostBars);
   if(validPostBars >= barsBack-1) { //still valid: allow preBars to value more, but not infinite, fresh levels are not that weighted!
      if(validPostBars >= stillGoingValueFactor)
         validy= MathMax(MathMin(validPostBars*(stillGoingValueFactor+1),validPreBars),validy);
      else
          validy= MathMax(MathMin(MathPow(validPostBars+1,2),validPreBars),validy);
      
   }
   validy= MathMin(sr_max_bars,validy);
  
   if(validy < sr_max_bars/firstFaktor) validy= MathPow(validy,2);
   else if(validy < sr_max_bars/5) validy *= sr_max_bars/firstFaktor;
   else {
      validy= MathPow(sr_max_bars,2)/(firstFaktor*5)+(validy-sr_max_bars/5.0)*(5.0*maxRange/4-sr_max_bars/(firstFaktor*4));
   }
   return validy/((maxRange*sr_max_bars/1000)*(barsBack-MathMin(sr_weight_max_post,validPostBars)));
}


double tbSRWeightFromBars(int barsBack, int validPreBars, int validPostBars, int violations) {
   if(sr_weight_type >= 0) {
     return(tbSRWeight(barsBack,validPreBars,validPostBars,sr_weight_type));
   } else {
     return(tbSRWeight(barsBack,validPreBars,validPostBars,0));   
   }
}

bool tbSRAddPrice(double price, double& array[][SR_ARRAY_IDX_COUNT],int barsBack, int validPreBars, int validPostBars, int violations, int pass) {
   int array_size= ArraySize(array)/SR_ARRAY_IDX_COUNT;
   double pip= price/tbPoint();
   double clusterPip= MathFloor(pip/sr_cluster_size)*sr_cluster_size+ (sr_cluster_size/2.0);
   double clusterPrice= NormalizeDouble(clusterPip*tbPoint(),Digits);
   if(sr_dynamic_clusters) {
      clusterPrice= price; //means cluster is created around this price
   }
   double fullClusterSize= sr_cluster_size*tbPoint();
   bool found= false;
   double weight= tbSRWeightFromBars(barsBack, validPreBars, validPostBars, violations);
   if(weight < 2) return(false);
   
   for(int i= 0; i < array_size;i++) {
      double delta= MathAbs(array[i][SR_ARRAY_PRICE_IDX] - price);
      if(pass > 0) {
         if((2*pass - 1)*fullClusterSize/2 < delta && delta <= (2*pass+1)*fullClusterSize/2) {
         double deltaInCluster= delta/fullClusterSize;
            array[i][SR_ARRAY_WEIGHT_IDX] += weight*(3/(3+deltaInCluster));
         }
         continue;
      }
      if(delta <= fullClusterSize/2) { //belongs to same cluster
         double oldWeight=array[i][SR_ARRAY_WEIGHT_IDX];
         array[i][SR_ARRAY_REAL_PRICE_IDX] = (array[i][SR_ARRAY_REAL_PRICE_IDX]*oldWeight+price*weight)/(oldWeight+weight);
         array[i][SR_ARRAY_WEIGHT_IDX] += weight;
         found= true;
         return(true);
      } else if(array[i][SR_ARRAY_PRICE_IDX] == 0)  { //just insert, forget the sorting etc. cause we have space left
         array[i][SR_ARRAY_PRICE_IDX] = clusterPrice;
         array[i][SR_ARRAY_WEIGHT_IDX]= weight;
         array[i][SR_ARRAY_REAL_PRICE_IDX]= price;
         found= true;
         return(true);
      }
   }
   if(!found && pass == 0) {
      ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);
      //if cluster with least weight has less weight than our weight, we add ourselfs and least weight gets removed
      //array is not sorted afterwards, but we dont care ;)
      if(array[array_size-1][SR_ARRAY_WEIGHT_IDX] <= weight) {
         array[array_size-1][SR_ARRAY_PRICE_IDX] = clusterPrice;
         array[array_size-1][SR_ARRAY_WEIGHT_IDX]= weight;
         array[array_size-1][SR_ARRAY_REAL_PRICE_IDX]= price;
         return(true);
      }
   }
   return(false);
}

double tbSRViolationDelta() {
   return tbPoint()*sr_violationBuffer;
}

bool tbSRIsValid(double extremePrice, int testIdx, int type) {
   double delta= tbSRViolationDelta();
   if(type == MODE_HIGH) {
      return extremePrice > iHigh(NULL,sr_period,testIdx) - delta;
    } else {
      return extremePrice < iLow(NULL,sr_period,testIdx)+delta;
    }
}

void tbSRGetValidy(int barIdx,int& preBars, int& postBars, int& violations, int type) {
   preBars= 0;
   int checkIdx= barIdx+1;
   double price= iLow(NULL,sr_period,barIdx);
   if(type == MODE_HIGH) price= iHigh(NULL,sr_period,barIdx);
   violations= 0;
   int preViolations= 0;
   int postViolations= 0;
   while(preBars < sr_max_bars && checkIdx < Bars) {
      if(!tbSRIsValid(price,checkIdx,type)) {
         preViolations++;
      }
      if(preViolations > sr_maxViolations) break;
      preBars++;
      checkIdx = barIdx + preBars+1;
   }
   
   postBars= 0;
   checkIdx= barIdx-1;
   while(checkIdx > 0 && postBars < sr_max_bars) {
      if(!tbSRIsValid(price,checkIdx,type)) {
         postViolations++;
      }
      if(postViolations > sr_maxViolations) break;
      postBars++;
      checkIdx = barIdx - postBars-1;
   }
   violations= MathMax(preViolations,postViolations);
}

int tbSRFillSupportResistance(double& array[][SR_ARRAY_IDX_COUNT],int type, int startIndex = 0, int maxBars= -1, int passes= 1)
{
  int index=0;
  double sum=0;
  int arraySize= ArraySize(array)/SR_ARRAY_IDX_COUNT;
  int i= 0;
  for(i= 0; i<arraySize; i++) {
   array[i][SR_ARRAY_PRICE_IDX]= 0;
   array[i][SR_ARRAY_WEIGHT_IDX]= 0;
   array[i][SR_ARRAY_REAL_PRICE_IDX]= 0;
  }
  //run throu all bars and check for support/resistance
  for(int pass= 0; pass < passes; pass++) {
     tbSRAddLevels(array,type,pass,startIndex,maxBars);
  }
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);
   int count= 0;
   for(i = 0;i< arraySize;i++) {
      if(array[i][0] != 0) count++;
      else break;
   }
   return count;
}

void tbSRAddLevels( double& array[][SR_ARRAY_IDX_COUNT],int type, int pass, int startIndex, int maxBars) {
 //run throu all bars and check for support/resistance
  double prevHigh, nextHigh, curHigh;
  double prevLow, nextLow, curLow;
  int idx= startIndex+2;
  prevHigh=  iHigh(NULL,sr_period,idx);
  curHigh=  iHigh(NULL,sr_period,idx-1);
  
  prevLow= iLow(NULL,sr_period,idx);
  curLow= iLow(NULL,sr_period,idx-1);
  
  double delta= tbSRViolationDelta();
  int preBars, postBars,violations;
  int bars= Bars;
  if(maxBars > 0) bars= MathMin(Bars,startIndex+maxBars);
  for(;idx < bars-1;idx++) {
  //update values
   nextHigh= curHigh;
   curHigh= prevHigh;
   prevHigh= iHigh(NULL,sr_period,idx+1);
   
   
   nextLow= curLow;
   curLow= prevLow;
   prevLow= iLow(NULL,sr_period,idx+1);
   
   //only consider local extremes with at least a validy of 1 in both sides
   if((type & SR_RESISTANCE) != 0 && prevHigh <= curHigh + delta && nextHigh <= curHigh + delta) {
      tbSRGetValidy(idx,preBars,postBars,violations,MODE_HIGH);
      if(tbSRAddPrice(curHigh,array,idx-startIndex,preBars,MathMin(idx-startIndex-1,postBars),violations,pass) && pass == 0 && sr_print_marker) {
            ObjectCreate("Marker_"+idx,OBJ_ARROW_UP,0,iTime(NULL,sr_period,idx),curHigh);
            ObjectSetText("Marker_"+idx," offset="+(idx-startIndex)+" weight="+tbSRWeightFromBars(idx-startIndex,preBars,MathMin(idx-startIndex-1,postBars),violations)
               +" pre "+preBars+" post "+MathMin(idx-startIndex-1,postBars)
               ,10);
         
      }     
   }
   
   if((type & SR_SUPPORT) != 0 && prevLow >= curLow - delta && nextLow >= curLow - delta) {
      tbSRGetValidy(idx,preBars,postBars,violations,MODE_LOW);
      if(tbSRAddPrice(curLow,array,idx-startIndex,preBars,MathMin(idx-startIndex-1,postBars),violations,pass) && pass == 0 && sr_print_marker) {
           ObjectCreate("Marker_"+idx,OBJ_ARROW_UP,0,iTime(NULL,sr_period,idx),curLow);
            ObjectSetText("Marker_"+idx," offset="+(idx-startIndex)
             +" weight="+tbSRWeightFromBars(idx-startIndex,preBars,MathMin(idx-startIndex-1,postBars),violations)
            +" pre "+preBars+" post "+MathMin(idx-startIndex-1,postBars)
            ,10);
         
      }
   }   
  }
}


void tbSRSetParams(int clusterSize,int maxPostForWeight= 500, int maxBars=500, int period= 0, int weightType= 1, int violationBuffer= 1, int maxViolations= 0, bool useDynamicCluster= false, bool printMarker= false) {
   sr_weight_max_post= maxPostForWeight;
   sr_max_bars= maxBars;
   sr_print_marker= printMarker;
   sr_cluster_size= clusterSize;
   sr_period= period;
   sr_weight_type= weightType;
   sr_maxViolations= maxViolations;
   sr_violationBuffer= violationBuffer;
   sr_dynamic_clusters= useDynamicCluster;
}