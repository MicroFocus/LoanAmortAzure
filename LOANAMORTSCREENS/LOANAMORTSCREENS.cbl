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
       PROGRAM-ID. LOANAMORTSCREENS.
       REMARKS. THIS PROGRAM CALCULATES A MONTHLY PAYMENT SCHEDULE AMOUNT BASED
               TERM, PRINCIPAL, AND INTEREST RATE. 

       ENVIRONMENT DIVISION.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       01 P PIC S9(8).
       01 T PIC S9(8).
       01 R PIC S9(9)V9(9).
       01 MONTH PIC S9(3).

       01 ERROR-MESSAGE PIC X(80).
       01 G-QUESTIONS-VALIDATED PIC 9.
         88 G-QUESTIONS-VALID VALUE 1.
         88 G-QUESTIONS-INVALID VALUE 2.

       01 DATAROW PIC X(80).

       01 COPY "AMORTIN.CPY".
       01 COPY "AMORTOUT.CPY".

       SCREEN SECTION.
       COPY "QUESTIONS.SS".
       
       PROCEDURE DIVISION.

           PERFORM UNTIL G-QUESTIONS-VALID
               SET G-QUESTIONS-VALID TO TRUE
               DISPLAY G-QUESTIONS
               ACCEPT G-QUESTIONS

               MOVE SPACES TO ERROR-MESSAGE

               IF P < 0
                   MOVE "INVALID LOAN AMOUNT" TO ERROR-MESSAGE
                   SET G-QUESTIONS-INVALID TO TRUE
               END-IF

               IF T < 1 OR T > 480 THEN
                   MOVE "TERM MUST BE BETWEEN 1 AND 480" TO ERROR-MESSAGE
                   SET G-QUESTIONS-INVALID TO TRUE
               END-IF
           END-PERFORM

           MOVE P TO PRINCIPAL
           MOVE T TO LOANTERM
           MOVE R TO RATE

           CALL "LOANAMORT" USING LOANINFO OUTDATA
           PERFORM VARYING MONTH FROM 1 BY 1 UNTIL MONTH = 10 OR MONTH >= LOANTERM
               STRING "PAYMENT #" MONTH " TOTAL " OUTPAYMENT(MONTH) " INT " OUTINTPAID(MONTH) " PRINCIPAL " OUTPRINCPAID(MONTH) INTO DATAROW
               DISPLAY DATAROW LINE (11 + MONTH) COL 1
           END-PERFORM

           DISPLAY "FINAL PAYMENT:" LINE 21 COL 1
           STRING "PAYMENT #" T " TOTAL " OUTPAYMENT(LOANTERM) " INT " OUTINTPAID(LOANTERM) " PRINCIPAL " OUTPRINCPAID(LOANTERM) INTO DATAROW
           DISPLAY DATAROW LINE 22 COL 1
           MOVE SPACES TO DATAROW
           STRING "TOTAL INTEREST " OUTTOTINTPAID INTO DATAROW
           DISPLAY DATAROW LINE 23 COL 1

           ACCEPT ERROR-MESSAGE
           
       END PROGRAM.
