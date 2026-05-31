package fr.n7.sn.mt.tp02solution;

/**
  * MonnaieErreurTest :
  *
  * @author	Xavier Crégut
  * @version	$Revision: 1.1 $
  */

public class MonnaieErreurTest extends MonnaieTest {

	public void testerEchec() {
		Assert.assertTrue(false);
	}

	public void testerFailure() {
		throw new RuntimeException("Test qui devait échouer !");
	}

}
