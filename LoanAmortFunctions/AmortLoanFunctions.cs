/*  
 *  (c) Copyright[2019] Micro Focus or one of its affiliates.
 *  
 *   Licensed under the Apache 2.0 License(the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at https://opensource.org/licenses/Apache-2.0 
   
 *   Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
 *   on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and limitations under the License.
*/

using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Net.Http.Headers;
using MicroFocus.COBOL.RuntimeServices.Generic;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;

namespace LoanAmortFunctions
{
    public static class AmortLoanFunctions
    {
        [FunctionName("GetPaymentSchedule")]
        public static HttpResponseMessage Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)]
            LoanParameters loanParameters,
            HttpRequestMessage req,
            TraceWriter log)
        {
            log.Info("C# HTTP trigger function processed a request.");

            if (!loanParameters.Validate())
            {
                return req.CreateErrorResponse(HttpStatusCode.BadRequest, String.Join(", ", loanParameters.Errors));
            }

            var loanData = CallLoanAmort(loanParameters, log);

            if(loanData == null)
            {
                return req.CreateErrorResponse(HttpStatusCode.BadRequest, "Failed to get loan term");
            }
            else
            {
                return req.CreateResponse(HttpStatusCode.OK, loanData, JsonMediaTypeFormatter.DefaultMediaType);
            }
        }

        private static LoanData CallLoanAmort(LoanParameters parameters, TraceWriter log)
        {
            // Map the parameters to the SmartLinkage input
            var loanInfo = new Loaninfo()
            {
                Loanterm = parameters.T,
                Principal = parameters.P,
                Rate = parameters.R
            };

            var outData = new Outdata();

            try
            {
                using (var runUnit = new RunUnit<LOANAMORT>())
                {
                    runUnit.Call(nameof(LOANAMORT), loanInfo.Reference, outData.Reference);
                }
            }
            catch(Exception ex)
            {
                log.Error("LOANAMORT run unit call failed", ex);
                return null;
            }

            var date = DateTime.Now;
            if(date.Day > 28)
            {
                var daysToAdjust = (date.Day - 28) * -1;
                date = date.AddDays(daysToAdjust);
            }

            var loanData = new LoanData();
            loanData.TotalInterest = outData.Outtotintpaid;

            for(int i = 0; i < loanInfo.Loanterm; i++)
            {
                var loanPayment = new AmortData()
                {
                    PayDateNo = string.Format("#{0} {1}", i, date.AddMonths(i+1).ToShortDateString()),
                    Payment = outData.get_Outpayment(i),
                    InterestPaid = outData.get_Outintpaid(i),
                    PrincipalPaid = outData.get_Outprincpaid(i),
                    Balance = outData.get_Outbalance(i)
                };
                loanData.AmortList.Add(loanPayment);
            }

            return loanData;
        }
    }
}
