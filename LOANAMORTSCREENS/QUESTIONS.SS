      * (c) Copyright [2019] Micro Focus or one of its affiliates.
      *
      * Licensed under the Apache 2.0 License (the "License");
      * you may not use this file except in compliance with the License.
      * You may obtain a copy of the License at https://opensource.org/licenses/Apache-2.0
      *
      * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
      * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      * See the License for the specific language governing permissions and limitations under the License.

       01 G-QUESTIONS.
       COPY "APPLICATIONHEADER.SS".
         02 LINE 5 COL 1 "PRINCIPAL : "
         02 LINE 5 COL 13 USING P AUTO
         02 LINE 6 COL 1 "LOAN TERM : "
         02 LINE 6 COL 13 PIC ZZ9 USING T AUTO
         02 LINE 7 COL 1 "RATE      : "
         02 LINE 7 COL 13 PIC Z9.99 USING R AUTO 
         02 LINE 9 COL 1 FROM ERROR-MESSAGE