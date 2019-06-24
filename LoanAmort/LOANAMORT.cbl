      * (c) Copyright [2019] Micro Focus or one of its affiliates.
      *
      * Licensed under the Apache 2.0 License (the "License");
      * you may not use this file except in compliance with the License.
      * You may obtain a copy of the License at https://opensource.org/licenses/Apache-2.0 
      *
      * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
      * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      * See the License for the specific language governing permissions and limitations under the License.


       IDENTIFICATION DIVISION.
       PROGRAM-ID. LOANAMORT.
       REMARKS. THIS PROGRAM CALCULATES A MONTHLY PAYMENT SCHEDULE AMOUNT BASED
               TERM, PRINCIPAL, AND INTEREST RATE. 

       ENVIRONMENT DIVISION.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       01 P PIC S9(8) COMP-3.
       01 T PIC S9(8) COMP-3.
       01 R PIC S9(9)V99(9).
       01 MONTH PIC S9(4) COMP.
       
       01 NUMPAYMENT PIC S9(9)V99.
       01 STRPAYMENT PIC $$,$$$.99.
       01 DECPAYMENT PIC S9(9)V9(9) COMP-3.
       01 INTPAID    PIC S9(9)V9(9).
       01 TOTINTPAID PIC S9(9)V9(9).
       01 PRINCPAID  PIC S9(8)V99 COMP-3.
       01 WORK-FIELDS.
          03 WRK-MESSAGE         PIC X(40) VALUE "CALCULATING PAYMENT".
          03 WRK-RATE            PIC S9(9)V9(9) COMP-3.
          03 WRK-PAYMENT         PIC S9(9)V9(9) COMP-3.
          03 WRK-PAYMENT-A       PIC $$,$$$.99.
       
       LINKAGE SECTION.
       01 COPY AMORTIN.
       01 COPY AMORTOUT.

       PROCEDURE DIVISION USING LOANINFO
                                OUTDATA.

      * Uncomment this code to get a clean set of passing tests
      *    if PRINCIPAL <= 0
      *        goback returning -1
      *    end-if

           PERFORM CALC-PAYMENT
           MOVE WRK-PAYMENT TO DECPAYMENT
           
           PERFORM VARYING MONTH FROM 1 BY 1 UNTIL MONTH > LOANTERM
               COMPUTE INTPAID ROUNDED = PRINCIPAL * ((RATE / 100) /12)
               COMPUTE TOTINTPAID = TOTINTPAID + INTPAID

               IF MONTH = LOANTERM
                   COMPUTE DECPAYMENT = INTPAID + PRINCIPAL
               END-IF    
               
               COMPUTE PRINCPAID = DECPAYMENT - INTPAID
               COMPUTE PRINCIPAL ROUNDED = PRINCIPAL - PRINCPAID
               MOVE PRINCPAID   TO OUTPRINCPAID(MONTH)
               MOVE INTPAID     TO OUTINTPAID(MONTH)
               MOVE DECPAYMENT  TO OUTPAYMENT(MONTH)
               MOVE PRINCIPAL   TO OUTBALANCE(MONTH)
               
           END-PERFORM
           MOVE TOTINTPAID TO         OUTTOTINTPAID

           GOBACK.
           
       CALC-PAYMENT.

           IF RATE = ZERO
               COMPUTE WRK-PAYMENT ROUNDED = PRINCIPAL / LOANTERM
           ELSE
               COMPUTE WRK-RATE = (RATE / 100) / 12
               COMPUTE WRK-PAYMENT  ROUNDED = (PRINCIPAL * WRK-RATE) /
                    (1 - (1 / ((1 + WRK-RATE) ** (LOANTERM))))
           END-IF.

       CALC-PAYMENT-EXIT.
           EXIT.
          
       END PROGRAM.
