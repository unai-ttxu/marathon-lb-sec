package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberRunner;
import com.stratio.tests.utils.BaseTest;;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/060_monitoring/01_EOS_3139_monitoring_IT.feature"
}, plugin = "json:target/cucumber.json")
public class EOS_3139_Monitoring_IT extends BaseTest {

    public EOS_3139_Monitoring_IT() {}

    @Test(enabled = true, groups = {"monitoring_MarathonLB"})
    public void monitoringMarathonLB() throws Exception{
        new CucumberRunner(this.getClass()).runCukes();
    }

}
