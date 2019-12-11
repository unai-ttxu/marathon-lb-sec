package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberFeatureWrapper;
import com.stratio.qa.cucumber.testng.PickleEventWrapper;
import com.stratio.qa.utils.BaseGTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = {
        "src/test/resources/features/functionalAT/060_monitoring/01_EOS_3139_monitoring_IT.feature"
}, plugin = "json:target/cucumber.json")
public class EOS_3139_Monitoring_IT extends BaseGTest {

    public EOS_3139_Monitoring_IT() {}

    @Test(enabled = true, groups = {"monitoring_MarathonLB"}, dataProvider = "scenarios")
    public void monitoringMarathonLB(PickleEventWrapper pickleWrapper, CucumberFeatureWrapper featureWrapper) throws Throwable {
        runScenario(pickleWrapper, featureWrapper);
    }

}
