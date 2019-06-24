      * (c) Copyright [2019] Micro Focus or one of its affiliates.
      *
      * Licensed under the Apache 2.0 License (the "License");
      * you may not use this file except in compliance with the License.
      * You may obtain a copy of the License at https://opensource.org/licenses/Apache-2.0
      *
      * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
      * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      * See the License for the specific language governing permissions and limitations under the License.

       COPY "MFUNIT_PROTOTYPES".

       IDENTIFICATION DIVISION.
       PROGRAM-ID. TESTLOANAMORT.

       ENVIRONMENT DIVISION.

       DATA DIVISION.

       WORKING-STORAGE SECTION.
       78 TESTINTERESTPAID VALUE "TESTINTERESTPAID".
       78 TESTPAYMENTFIVE VALUE "TESTPAYMENTFIVE".
       78 TESTPRINCIPLEATTERMEND VALUE "TESTPRINCIPLEATTERMEND".
       COPY "MFUNIT".

       COPY AMORTIN.
       COPY AMORTOUT.

       PROCEDURE DIVISION.

      *> VERIFY THAT LOAN PROGRAM RETURNS THE EXPECTED TOTAL INTEREST AMOUNT
       ENTRY MFU-TC-PREFIX & TESTINTERESTPAID.

           MOVE 10000 TO PRINCIPAL
           MOVE 24 to LOANTERM
           MOVE 2.5 to RATE

           call "LOANAMORT" USING LOANINFO OUTDATA

           IF 262.50 = FUNCTION NUMVAL(OUTTOTINTPAID)
               GOBACK RETURNING MFU-PASS-RETURN-CODE
           ELSE
               EXHIBIT NAMED OUTTOTINTPAID
               GOBACK RETURNING MFU-FAIL-RETURN-CODE
           END-IF
       .

      *> VERIFY OUTPUT VALUES MATCH OUR EXPECTATIONS AFTER 5 PAYMENTS
       ENTRY MFU-TC-PREFIX & TESTPAYMENTFIVE.

           MOVE 10000 TO PRINCIPAL
           MOVE 24 to LOANTERM
           MOVE 2.5 to RATE

           call "LOANAMORT" USING LOANINFO OUTDATA

           IF 17.43 <> FUNCTION NUMVAL(OUTINTPAID OF PAYMENTS(5))
               EXHIBIT NAMED OUTINTPAID OF PAYMENTS(5)
               GOBACK RETURNING MFU-FAIL-RETURN-CODE
           END-IF

           IF 410.17 <> FUNCTION NUMVAL(OUTPRINCPAID OF PAYMENTS(5))
               EXHIBIT NAMED OUTPRINCPAID OF PAYMENTS(5)
               GOBACK RETURNING MFU-FAIL-RETURN-CODE
           END-IF

           IF 427.60 <> FUNCTION NUMVAL(OUTPAYMENT OF PAYMENTS(5))
               EXHIBIT NAMED OUTPAYMENT OF PAYMENTS(5)
               GOBACK RETURNING MFU-FAIL-RETURN-CODE
           END-IF

           IF 7958.00 <> FUNCTION NUMVAL(OUTBALANCE OF PAYMENTS(5))
               EXHIBIT NAMED OUTBALANCE OF PAYMENTS(5)
               GOBACK RETURNING MFU-FAIL-RETURN-CODE
           END-IF

           GOBACK RETURNING MFU-PASS-RETURN-CODE
       .

      *> VERIFY THAT THE PRINCIPLE IS ZERO AT THE END OF THE LOAN TERM
       ENTRY MFU-TC-PREFIX & TESTPRINCIPLEATTERMEND.

           MOVE 10000 TO PRINCIPAL
           MOVE 24 to LOANTERM
           MOVE 2.5 to RATE

           call "LOANAMORT" USING LOANINFO OUTDATA

           IF 0 <> FUNCTION NUMVAL(OUTBALANCE OF PAYMENTS(24))
               EXHIBIT NAMED OUTBALANCE OF PAYMENTS(24)
               GOBACK RETURNING MFU-FAIL-RETURN-CODE
           END-IF

           GOBACK RETURNING MFU-PASS-RETURN-CODE
       .

       ENTRY MFU-TC-PREFIX & "TESTZEROLOANAMOUNT".

           move 0 to PRINCIPAL
           move 0 to LOANTERM
           move 0 to RATE

           call "LOANAMORT" USING LOANINFO
                                  OUTDATA

           if return-code not = -1 
               exhibit return-code
               call "MFU_ASSERT_FAIL_Z" using "return code should be -1 for zero loan amount. " & x"00"
               GOBACK RETURNING MFU-FAIL-RETURN-CODE
           end-if

           goback returning MFU-PASS-RETURN-CODE

       .
          
       END PROGRAM.
