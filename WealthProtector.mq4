//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
//| MyFirstEA.mq4 |
//| Copyright 2017, |
//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
#property copyright "Copyright 2017"
#property link ""
#property version "1"
#property strict
//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
sinput string tt = "Торговые настройки";
input double Lot = 0.01;
input int TakeProfit = 300;
input int StopLoss = 300;
input int Slippage = 30;
sinput string en = "Настройка Envelopes";
input int period = 14;
input double deviation=0.10;
sinput string zz = "Настройка ZZ";
input int Depth = 12;
input int Deviation= 5;
input int BackStep = 3;
input int Magic=254521;
double enveUP, enveDW, ZZ;
datetime open;
//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
int OnInit()
  {
   return (INIT_SUCCEEDED);
  }
//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
//| |
//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
void OnDeinit(const int reason)
  {
  }
//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
//| |
//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
void OnTick()
  {
  
  
   double a  = iCustom(NULL, 0, "Envelopes alert mod", 0, 2, 0); 
 
    
   if(CountTrades(OP_BUY, Magic) ==0 && Ask <OrderOpenPrice() && a == 1)
      openOrders
      (OP_BUY, Lot);
   if(CountTrades(OP_SELL, Magic) ==0 && Bid> OrderOpenPrice()  && a == 2)
      openOrders
      (OP_SELL, Lot);
   if(CountTrades(OP_BUY, Magic)> 0 && Bid> OrderOpenPrice() && a == 1)
      closeOrders(OP_BUY, Magic);
   if(CountTrades(OP_SELL, Magic)> 0 && Ask <OrderOpenPrice() && a == 2)
      closeOrders(OP_SELL, Magic);
  }
//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
int CountTrades(int type, int magic)
  {
   int count = 0;
   for(int i = OrdersTotal() -1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() ==Symbol() && (OrderType() ==type || type==-1) && (OrderMagicNumber()
               ==magic || magic==-1))
            count++;
        }
     }
   return (count);
  }
//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
//| |
//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
void openOrders(int type, double lot)
  {
   int ticket;
   double price;
   if(type == OP_BUY)
      price = Ask;
   if(type == OP_SELL)
      price = Bid;
   if(price <= 0)
      return;
   ticket=OrderSend(Symbol(),type, lot, price, Slippage,0,0,"", Magic,0,clrLimeGreen);
   if(ticket> 0)
     {
      //Устанавливаем Стоп-лосс и Тейк-профит для Бай-ордера
      if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
        {
         double sl, tp;
         if(type==OP_BUY)
           {
            sl=OrderOpenPrice()-(StopLoss*_Point);
            sl=NormalizeDouble(sl,_Digits);
            tp=OrderOpenPrice() + (TakeProfit*_Point);
            tp=NormalizeDouble(tp,_Digits);
           }
         if(type==OP_SELL)
           {
            sl=OrderOpenPrice() + (StopLoss*_Point);
            sl=NormalizeDouble(sl,_Digits);
            tp=OrderOpenPrice()-(TakeProfit*_Point);
            tp=NormalizeDouble(tp,_Digits);
           }
         bool mod=false;
         int count=0;
         while(!mod)
           {
            mod=OrderModify(ticket, OrderOpenPrice(),sl, tp,0,clrYellow);
            count++;
            if(count>=100)
              {
               mod=true;
               break;
              }
           }
        }
     }
  }
//Функция закрытия ордеров
void closeOrders(int type, int magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderMagicNumber() ==magic || magic==-1)
           {
            if(OrderSymbol() ==Symbol() && (OrderType() ==type || type==-1))
              {
               if(OrderType() ==OP_BUY)
                 {
                  OrderClose(OrderTicket(),OrderLots(),Bid, Slippage, clrAqua);
                 }
               if(OrderType() ==OP_SELL)
                 {
                  OrderClose(OrderTicket(),OrderLots(),Ask, Slippage, clrAqua);
                 }
              }
           }
        }
     }
  }
//+ - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - — - +
//+------------------------------------------------------------------+
