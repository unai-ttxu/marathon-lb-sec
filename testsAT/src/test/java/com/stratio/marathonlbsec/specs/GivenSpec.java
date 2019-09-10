/*
 * Copyright (C) 2015 Stratio (http://stratio.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.stratio.marathonlbsec.specs;

import com.stratio.qa.utils.ThreadProperty;
import cucumber.api.java.en.Given;

public class GivenSpec extends BaseSpec {
   
    public GivenSpec(Common spec) {
	this.commonspec = spec;
    }

    @Given("^I set variables to login in custom tenant$")
    public void setTenantVariables() throws Exception {
        String dcosUser = System.getProperty("DCOS_TENANT_USER") != null ? System.getProperty("DCOS_TENANT_USER") : ThreadProperty.get("DCOS_USER");
        String dcosPassword = System.getProperty("DCOS_TENANT_PASSWORD") != null ? System.getProperty("DCOS_TENANT_PASSWORD") : System.getProperty("DCOS_PASSWORD");;
        ThreadProperty.set("DCOS_TENANT_USER", dcosUser);
        ThreadProperty.set("DCOS_TENANT_PASSWORD", dcosPassword);
    }
}