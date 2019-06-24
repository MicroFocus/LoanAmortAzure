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

using System.Collections.Generic;

namespace LoanAmortFunctions
{
    public class LoanParameters
    {
        public int P { get; set; }
        public int T { get; set; }
        public decimal R { get; set; }
        public IList<string> Errors { get; }

        public LoanParameters()
        {
            Errors = new List<string>();
        }

        internal bool Validate()
        {
            Errors.Clear();

            if (P < 1)
                Errors.Add("Principal must be greater than 0");

            if (T < 1)
                Errors.Add("Term must be greater that 0 ");

            return Errors.Count == 0;
        }
    }
}