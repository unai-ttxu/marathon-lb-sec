package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberRunner;
import com.stratio.tests.utils.BaseTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = { "src/test/resources/features/functionalAT/CCT_Uninstall_IT.feature" },format = "json:target/cucumber.json")
public class Uninstall_CCT_IT extends BaseTest {

    public Uninstall_CCT_IT() {
    }

    @Test(enabled = true, groups = {"uninstall_cct"})
    public void installation() throws Exception {
        new CucumberRunner(this.getClass()).runCukes();
    }
}
