# -*- coding: utf-8 -*-
require 'test/unit'
require_relative '../lib/jusolink.rb'

class JusolinkTest < Test::Unit::TestCase
  LinkID = "TESTER_JUSO"
  SecretKey = "FjaRgAfVUPvSDHTrdd/uw/dt/Cdo3GgSFKyE1+NQ+bc="

  JUSOInstance = Jusolink.instance(JusolinkTest::LinkID, JusolinkTest::SecretKey)

  def test_01ServiceInstance
    cbInstance = Jusolink.instance(
      JusolinkTest::LinkID,
      JusolinkTest::SecretKey,
    )
    puts cbInstance
    assert_not_nil(cbInstance)
  end

  def test_02getBalance
    remainPoint = JUSOInstance.getBalance
    puts remainPoint
    assert_not_nil(remainPoint)
  end

  def test_03SingletonTest
    instance01 = Jusolink.instance(
      JusolinkTest::LinkID,
      JusolinkTest::SecretKey,
    )

    instance02 = Jusolink.instance(
      JusolinkTest::LinkID,
      JusolinkTest::SecretKey,
    )
    assert_equal(instance01, instance02)
  end

  def test_04getUnitCost
    unitCost = JUSOInstance.getUnitCost
    puts unitCost
    assert_not_nil(unitCost)
  end

  def test_05search
    response = JUSOInstance.search("반룡로28번길", 1, 20)

    puts response

    assert_not_nil(response)
  end


end # end of test Class
