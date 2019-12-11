package com.stratio.marathonlbsec.functionalAT;

import com.stratio.qa.cucumber.testng.CucumberFeatureWrapper;
import com.stratio.qa.cucumber.testng.PickleEventWrapper;
import com.stratio.qa.utils.BaseGTest;
import cucumber.api.CucumberOptions;
import org.testng.annotations.Test;

@CucumberOptions(features = { "src/test/resources/features/functionalAT/030_Logs/03_QATM_2113_Vault_Renewal_Token.feature" },plugin = "json:target/cucumber.json")
public class QATM_2113_Vault_Renewal_Token_IT extends BaseGTest {

    public QATM_2113_Vault_Renewal_Token_IT() {

    }

    @Test(enabled = true, groups = {"vaultRenewalToken"}, dataProvider = "scenarios")
    public void QATM1386_Certificates(PickleEventWrapper pickleWrapper, CucumberFeatureWrapper featureWrapper) throws Throwable {
        runScenario(pickleWrapper, featureWrapper);
    }
}
