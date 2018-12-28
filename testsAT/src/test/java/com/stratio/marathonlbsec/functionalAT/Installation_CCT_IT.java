package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberRunner;
import com.stratio.qa.data.BrowsersDataProvider;
import com.stratio.tests.utils.BaseTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Factory;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/010_Installation/CCT_Installation_IT.feature"
},format = "json:target/cucumber.json")

public class Installation_CCT_IT extends BaseTest {

    public Installation_CCT_IT() {
    }

    @Test(enabled = true, groups = {"installation_cct"})
    public void AppWithSecurityES() throws Exception {
        new CucumberRunner(this.getClass()).runCukes();
    }
}