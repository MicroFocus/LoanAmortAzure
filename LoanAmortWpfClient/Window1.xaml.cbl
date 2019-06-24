       class-id AmortWPFClient.Window1 is partial
                 inherits type System.Windows.Window.

       working-storage section.
       method-id NEW.
       procedure division.
           invoke self::InitializeComponent()
           goback.
       end method.

       method-id btnAmort_Click.
       01 AmortURL String value "http://localhost:7071/api/GetPaymentSchedule".
       01 wc type WebClient.
       01 jSer type DataContractJsonSerializer.
       01 result type Byte occurs any.
       01 LoanDataObj type LoanData.
       01 AmortList List[type AmortData].
       
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
           declare P = tbPrincipal::Text
           declare T = tbMonths::Text
           declare R = tbRate::Text

           set AmortURL to AmortURL & "?P=" & P & "&" & "T=" & T & "&" & "R=" & R
           set wc to new WebClient

           set result to wc::DownloadData(AmortURL)
           declare ms = new MemoryStream(result)
           set jSer to new DataContractJsonSerializer(type of LoanData)
           set LoanDataObj to jSer::ReadObject(ms) as type LoanData
           
           set AmortList to LoanDataObj::AmortList
           set dgAmortData::ItemsSource to AmortList
           set lblTotInterest::Content to LoanDataObj::TotalInterest
           set lblInterest::Visibility to type Visibility::Visible
           
           goback.

       end method.

       
       class-id LoanData.
       01 AmortList      List[type AmortData] property.
       01 TotalInterest  String               property.
       end class.

       class-id AmortData.
       01 PayDateNo        String property.
       01 InterestPaid     String property.
       01 PrincipalPaid    String property.
       01 Payment          String property.
       01 Balance          String property.
       end class.

       end class.
       

