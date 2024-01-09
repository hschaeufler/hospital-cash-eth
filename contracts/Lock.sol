// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract HealthContract {

    function getHospitalCashPremium(uint age, uint hospitalCashInWei) public pure returns (uint premiumInWei) {
        require(hospitalCashInWei > 1000, "Hospitalcash must be greater then 1000 Wei");
        premiumInWei = getHospitalCashFactorFromAge(age) * hospitalCashInWei / 1000;
    }

    function getHospitalCashFactorFromAge(uint age) internal pure returns (uint) {
            if(age <= 16) {
                return 56;
            } else if(age <= 20) {
                return 70;
            } else if(age <= 25){
                return (age - 21) * 6 + 184;
            } else if(age <= 28) {
                return (age - 26) * 6 + 216;
            } else if(age == 29) {
                return 236;
            } else if (age <= 37) {
                return (age - 30) * 8 + 242;
            } else if(age <= 42) {
                return (age - 38) * 10 + 360;
            } else if(age == 47) {
                return 410;
            } else if(age <= 50) {
                return (age - 48) * 14 + 422;
            } else if(age <= 50) {
                return (age - 48) * 14 + 422;
            } else if(age == 51) {
                return 466;
            } else if(age == 52) {
                return 480;
            } else if(age == 53) {
                return 496;
            } else if(age == 54) {
                return 510;
            } else if(age == 55) {
                return 526;
            } else if(age == 56) {
                return 544;
            } else if(age == 57) {
                return 560;
            } else if(age == 58) {
                return 578;
            } else if(age <= 62) {
                return (age - 59) * 18 + 594;
            } else if(age == 63) {
                return 668;
            } else if(age == 64) {
                return 686;
            } else {
                revert("Age should be greater than 0 and lower than 65");
            }
    }
}
