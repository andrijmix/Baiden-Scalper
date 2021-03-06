//+------------------------------------------------------------------+
//|                                                     WebUtils.mqh |
//|                      Copyright 2020, Igor Ryabchikov (aka Rigal) |
//|                     https://tlap.com/forum/profile/109537-rigal/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Igor Ryabchikov (aka Rigal)"
#property link      "https://tlap.com/forum/profile/109537-rigal/"
#property strict

#ifndef NO_DLL
   #import "wininet.dll"
   #define INTERNET_FLAG_PRAGMA_NOCACHE   0x00000100  // no caching of page
   #define INTERNET_FLAG_KEEP_CONNECTION  0x00400000  // keep connection
   #define INTERNET_FLAG_RELOAD           0x80000000  // get page from server when calling it

   int InternetAttemptConnect(int x);
   int InternetOpenW(string sAgent,int lAccessType,
                  string sProxyName="",string sProxyBypass="",
                  int lFlags=0);
   int InternetReadFile(int, uchar &sBuffer[], int, int& OneInt);
   int InternetConnectW(int, string, int, string, string, int, int, int); 
   int HttpOpenRequestW(int, string, string, string, string, string& AcceptTypes[], int, int);
   bool HttpSendRequestW(int, string, int, string, int);

   int InternetOpenUrlW(int hInternetSession,string sUrl,
                        string sHeaders="",int lHeadersLength=0,
                        int lFlasgs=0,int lContext=0);
   int InternetReadFile(int hFile,int &sBuffer[],int lNumBytesToRead,
                        int &lNumberOfBytesRead[]);
   int InternetCloseHandle(int hInet);
   #import
#import "kernel32.dll"
   int GetLastError(void);
#import
#endif
#include "Logger.mqh"
/*      responseSize = WebRequest("GET", timeURL, cookie, NULL, 7000, msgBody, 0, response, responseHeaders);
      if (responseSize == -1) {
         Print("Error in web request: ", GetLastError(), " | ", CharArrayToString(response,0,-1,0)); 
         Print("If you want to check whether the GMT offset is correct, please allow web requests to: http://worldclockapi.com"); 
      } else {
         responseStr = CharArrayToString(response,0,-1,0) ;
         Print("Got this from web:", responseStr);
*/

class CWebUtils {
   static string ParseRoot(const string _url) {
      int startPos = StringFind(_url, "//") + 2;
      if(startPos < 0)
         startPos = 0;
      int pos = StringFind(_url, "/", startPos);
      if(pos < 0) {
         pos = StringFind(_url, "?", startPos);
      }
      if(pos < 0)
         return (_url);
      return (StringSubstr(_url, 0, pos));
   }
public:
   //////////////////////////////////////////////////////////////////////////////////
   // Скачивает исходный код страницы CBOE  в текстовую переменную 
   //                и возвращает как результат
   //////////////////////////////////////////////////////////////////////////////////
   static string Get(const string _url) {
      string TXT = "";
#ifndef NO_DLL
      if(!IsDllsAllowed()){
          Alert("Please enable DLL!");
          return("");
        }
      int rv = InternetAttemptConnect(0);
      if(rv != 0) {
          Alert("InternetAttemptConnect() failed");
          return("");
      }
      int hInternetSession = InternetOpenW("Microsoft Internet Explorer", 
                                           0, "", "", 0);
      if(hInternetSession <= 0) {
          Alert("InternetOpenA() failed");
          return("");         
      }
      int hURL = InternetOpenUrlW(hInternetSession, 
                 _url, "", 0, 0, 0);
      if(hURL <= 0) {
          Alert("InternetOpenUrlA() failed");
          InternetCloseHandle(hInternetSession);
          return("");         
      }      
      int cBuffer[256];
      int dwBytesRead[1]; 
      while(!IsStopped()) {
         bool bResult = InternetReadFile(hURL, cBuffer, 1024, dwBytesRead);
         if(dwBytesRead[0] == 0)
             break;
         string text = "";   
         string text0= "";   
         for(int i = 0; i < 256; i++) {
            text0= CharToStr((char)(cBuffer[i] & 0x000000FF));
            if (text0!="\r") text = text + text0;
            else dwBytesRead[0]--;
            if(StringLen(text) == dwBytesRead[0]) break;
            
            text0= CharToStr((char)(cBuffer[i] >> (8 & 0x000000FF)));
            if (text0!="\r") text = text + text0;
            else dwBytesRead[0]--;
            if(StringLen(text) == dwBytesRead[0]) break;
            
            text0= CharToStr((char)(cBuffer[i] >> (16 & 0x000000FF)));
            if (text0!="\r") text = text + text0;
            else dwBytesRead[0]--;
            if(StringLen(text) == dwBytesRead[0]) break;
            
            text0= CharToStr((char)(cBuffer[i] >> (24 & 0x000000FF)));
            if (text0!="\r") text = text + text0;
            else dwBytesRead[0]--;
            if(StringLen(text) == dwBytesRead[0]) break;
                 
        }
        TXT = TXT + text;
        Sleep(1);
      }
      InternetCloseHandle(hInternetSession);
#else
      string cookie = NULL ;
      string    responseHeaders;
      char      msgBody[];
      char      response[];
      ResetLastError();
      int responseSize = WebRequest("GET", _url, cookie, NULL, 7000, msgBody, 0, response, responseHeaders);
      if (responseSize == -1) {
         Print("Error in web request: ", GetLastError(), " | ", CharArrayToString(response,0,-1,0)); 
         Alert("Please allow web requests to: ", ParseRoot(_url));
      } else {
         TXT = CharArrayToString(response,0,-1,0);
      }
#endif
      return(TXT);
   }
   ////////////////////////////////////////////////////////////////////////////////////
   static string PostAndGet(const string _post, const string _root, const int _port, const string _path, 
                     const string _headers = "Content-Type: application/json;charset: utf-8\r\nAccept: application/json") {
      string result = "";
#ifndef NO_DLL
      if(!IsDllsAllowed()){
         Alert("Please enable DLL!");
         return("");
      }

      int rv = InternetAttemptConnect(0);
      if(rv == 0) {
         int hInternetSession = InternetOpenW("HTTP_Client", 1, NULL, NULL, 0);
         if(hInternetSession > 0) {
            int httpConnect = InternetConnectW(hInternetSession, _root, _port, "", "", 3, 0, 0);
            if(httpConnect > 0) {
               string acceptTypes[] = {"application/json", NULL};
               int httpRequest = HttpOpenRequestW(httpConnect, "POST", _path, NULL, NULL, acceptTypes, 0, 1);
               if(httpRequest > 0) { 
                  logger.Trace("POST: " + _post); 
                  bool postResult = HttpSendRequestW(httpRequest, _headers, StringLen(_headers), _post, StringLen(_post) * 2);
            
                  if(postResult) {
                     uchar ch[500];
                     int dwBytes;
                     while(InternetReadFile(httpRequest, ch, 500, dwBytes)) {
                        if(dwBytes <= 0) break;
                        result = result + CharArrayToString(ch, 0, dwBytes);
                     }
                  } else {
                     logger.Trace("POST failed, last MSDN Error: " + IntegerToString(kernel32::GetLastError()));
                  }
                  InternetCloseHandle(httpRequest);
               }

            } else
               logger.Trace("Web request failure, last MSDN Error : " + IntegerToString(kernel32::GetLastError()));
         }
         if(hInternetSession > 0)
            InternetCloseHandle(hInternetSession);
      }                
#else
      char post[], response[];
      int res;
      string url, response_header;
      
      url = StringConcatenate(_root, _path);
      if(StringFind(url, "://") == -1)
         url = StringConcatenate("http://", url); 
      //--- Reset the last error code
      ResetLastError();
      int timeout =  5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection
      
      StringToCharArray(_post, post, 0, StringLen(_post));
      
      res = WebRequest("POST", url, _headers, timeout, post, response, response_header);
      
      //--- Checking errors
      if(res == -1) {
         Print("Error in WebRequest. Error code  =", GetLastError());
         //--- Perhaps the URL is not listed, display a message about the necessity to add the address
         Alert("Please allow web requests to: " + _root);
      } else {
         for(int i = 0; i < ArraySize(response); i++) {
             if((result[i] == 10) || (response[i] == 13)) {
                continue;
             } else {
                result += CharToStr(response[i]);
             }
         }
      }
#endif   
      logger.Trace("Response: " + result);
      return (result);
   }

};