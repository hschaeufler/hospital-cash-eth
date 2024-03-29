// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract HospitalCash is Ownable {
    struct HealthQuestions {
        bool hasNoInpatientTreatment;
        bool hasNoOutpatientTreatment;
        bool hasNoPsychotherapy;
        bool hasNoChronicIllness;
        bool hasNoMedication;
    }

    struct InsuranceContract {
        uint policyId;
        uint insuranceStartDate;
        uint insuranceEndDate;
        uint dailyHospitalCashInWei;
        uint paidPremiumInWei;
        uint lastPayOutDate;
        int birthday;
    }

    struct BodyMeasure {
        uint heightInCm;
        uint weightInKg;
    }

    struct PremiumCalculation {
        int birthDate;
        uint insuranceStartDate;
        uint hospitalCashInWei;
    }

    struct ContractApplication {
        HealthQuestions healthQuestions;
        PremiumCalculation premiumCalculation;
        BodyMeasure bodyMeasure;
    }

    struct StepDateCount {
        uint date;
        uint steps;
    }

    struct InsuranceClaim {
        uint policyId;
        uint admissionDate;
        uint releaseDate;
    }

    // first policyId is 1
    uint internal policyIdCounter = 1;
    mapping(address => InsuranceContract) public contracts;
    mapping(uint => address) public policyHolder;
    uint public constant dailyStepLimit = 8000;
    uint public constant discountFraction = 10;

    event NewContract(
        address indexed policyHolder,
        uint policyId,
        uint insuranceStartDate,
        uint insuranceEndDate,
        uint dailyHospitalCashInWei
    );

    event NewPayout(
        uint policyId,
        uint admissionDate,
        uint releaseDate,
        uint payoutAmount
    );

    constructor() Ownable(msg.sender) {}

    function checkHealthQuestions(
        HealthQuestions calldata healthQuestions
    ) public pure returns (bool) {
        return
            healthQuestions.hasNoInpatientTreatment &&
            healthQuestions.hasNoOutpatientTreatment &&
            healthQuestions.hasNoPsychotherapy &&
            healthQuestions.hasNoChronicIllness &&
            healthQuestions.hasNoMedication;
    }

    function calculateBMI(
        uint heightInCm,
        uint weightInKg
    ) public pure returns (uint bmi) {
        // Needs to Multiply weight with 100²
        // because height is in cm and not in m
        bmi = (weightInKg * 100 * 100) / (heightInCm * heightInCm);
    }

    function checkBMI(
        uint heightInCm,
        uint weightInKg
    ) public pure returns (uint bmi, bool isOk) {
        bmi = calculateBMI(heightInCm, weightInKg);
        require(bmi < 30, "Your bmi must be lower than 30.");
        require(bmi > 17, "Your bmi must be greater than 17.");
        isOk = true;
    }

    function getMonthlyPremium(
        int birthDate,
        uint insuranceStartDate,
        uint hospitalCashInWei
    ) public view returns (uint premiumInWei) {
        require(
            hospitalCashInWei > 1000,
            "Hospitalcash must be greater then 1000 Wei"
        );
        require(
            birthDate < int(block.timestamp),
            "Birtday is not allowed to be in the future."
        );
        require(
            block.timestamp < insuranceStartDate,
            "The insurance start date need to be in the future."
        );
        require(
            insuranceStartDate < (block.timestamp + 182 days),
            "The insurance start date may not be more than 6 months in the future."
        );
        require(
            birthDate < int(insuranceStartDate),
            "Birthday must be before Insurance day"
        );
        uint age = calculateAgeAtInsuranceStart(birthDate, insuranceStartDate);
        require(age > 18, "Person must be an adult!");
        require(age < 65, "Person is not allowed to be older then 65");
        premiumInWei =
            (getHospitalCashFactorFromAge(age) * hospitalCashInWei) /
            1000;
    }

    function calculateAgeAtInsuranceStart(
        int birthDate,
        uint insuranceStartDate
    ) internal pure returns (uint age) {
        age = uint((int(insuranceStartDate) - birthDate) / 365 days);
    }

    function getHospitalCashFactorFromAge(
        uint age
    ) internal pure returns (uint) {
        if (age <= 16) {
            return 56;
        } else if (age <= 20) {
            return 70;
        } else if (age <= 25) {
            return ((age - 21) * 6) + 184;
        } else if (age <= 28) {
            return ((age - 26) * 6) + 216;
        } else if (age == 29) {
            return 236;
        } else if (age <= 37) {
            return ((age - 30) * 8) + 242;
        } else if (age <= 42) {
            return ((age - 38) * 10) + 308;
        } else if (age <= 46) {
            return ((age - 43) * 12) + 360;
        } else if (age == 47) {
            return 410;
        } else if (age <= 50) {
            return ((age - 48) * 14) + 422;
        } else if (age == 51) {
            return 466;
        } else if (age == 52) {
            return 480;
        } else if (age == 53) {
            return 496;
        } else if (age == 54) {
            return 510;
        } else if (age == 55) {
            return 526;
        } else if (age == 56) {
            return 544;
        } else if (age == 57) {
            return 560;
        } else if (age == 58) {
            return 578;
        } else if (age <= 62) {
            return ((age - 59) * 18) + 594;
        } else if (age == 63) {
            return 668;
        } else if (age == 64) {
            return 686;
        } else {
            revert("Age should be greater than 0 and lower than 65");
        }
    }

    function getNextPolicyId() internal returns (uint) {
        return policyIdCounter++;
    }

    function hasContract(
        address policyHolderAddress
    ) internal view returns (bool) {
        return contracts[policyHolderAddress].policyId != 0;
    }

    function hasValidContract(
        address policyHolderAddress
    ) internal view returns (bool) {
        return
            contracts[policyHolderAddress].policyId != 0 &&
            block.timestamp < contracts[policyHolderAddress].insuranceEndDate;
    }

    function applyForInsurace(
        ContractApplication calldata application
    ) external payable {
        HealthQuestions calldata healthQuestions = application.healthQuestions;
        BodyMeasure calldata bodyMeasure = application.bodyMeasure;
        PremiumCalculation calldata premiumCalculation = application
            .premiumCalculation;

        require(
            !hasValidContract(msg.sender),
            "Policyholder is already insured"
        );
        require(
            checkHealthQuestions(healthQuestions),
            "Policyholder must not have any health problems."
        );
        (, bool isOK) = checkBMI(
            bodyMeasure.heightInCm,
            bodyMeasure.weightInKg
        );
        require(isOK, "BMI is not suitable.");
        uint monthlyPremium = getMonthlyPremium(
            premiumCalculation.birthDate,
            premiumCalculation.insuranceStartDate,
            premiumCalculation.hospitalCashInWei
        );
        uint yearlyPremium = 12 * monthlyPremium;
        require(
            msg.value >= yearlyPremium,
            "Paid amount must be at least the calculated premium."
        );

        // send back unnecessary ether
        uint difference = msg.value - yearlyPremium;
        if (difference > 0) {
            payable(msg.sender).transfer(difference);
        }

        uint policyId = getNextPolicyId();
        uint insuranceEndDate = premiumCalculation.insuranceStartDate +
            365 days;
        InsuranceContract memory insuranceContract = InsuranceContract({
            insuranceStartDate: premiumCalculation.insuranceStartDate,
            insuranceEndDate: insuranceEndDate,
            dailyHospitalCashInWei: premiumCalculation.hospitalCashInWei,
            policyId: policyId,
            paidPremiumInWei: yearlyPremium,
            lastPayOutDate: premiumCalculation.insuranceStartDate,
            birthday: premiumCalculation.birthDate
        });
        contracts[msg.sender] = insuranceContract;
        policyHolder[policyId] = msg.sender;

        emit NewContract(
            msg.sender,
            insuranceContract.policyId,
            insuranceContract.insuranceStartDate,
            insuranceContract.insuranceEndDate,
            insuranceContract.dailyHospitalCashInWei
        );
    }

    function hasContract() external view returns (bool) {
        return hasContract(msg.sender);
    }

    function hasValidContract() external view returns (bool) {
        return hasValidContract(msg.sender);
    }

    function getContract()
        external
        view
        returns (bool isValid, InsuranceContract memory insuranceContract)
    {
        isValid = hasContract(msg.sender);
        insuranceContract = contracts[msg.sender];
    }

    function getValidContract()
        external
        view
        returns (bool isValid, InsuranceContract memory insuranceContract)
    {
        isValid = hasValidContract(msg.sender);
        insuranceContract = contracts[msg.sender];
    }

    function getLastPayOutDate() external view returns (uint) {
        require(hasValidContract(msg.sender),"Caller has no valid contract");
        return contracts[msg.sender].lastPayOutDate;
    }

    function claimDiscount(StepDateCount[] calldata discountClaims) external {
        require(discountClaims.length > 0, "Nothing to claim!");
        require(discountClaims.length <= 7, "No more then seven claims");
        require(hasValidContract(msg.sender), "Sender is is not insured");
        InsuranceContract memory insuranceContract = contracts[msg.sender];
        require(
            insuranceContract.insuranceStartDate < block.timestamp,
            "Insurance period has not yet begun"
        );

        uint lastPayOutDate = insuranceContract.lastPayOutDate;

        uint validClaims = 0;
        for (uint i = 0; i < discountClaims.length; i++) {
            StepDateCount memory discountClaim = discountClaims[i];
            require(
                discountClaim.date < block.timestamp,
                "No claims from the future allowed."
            );
            bool isValid = discountClaim.date <
                insuranceContract.insuranceEndDate &&
                discountClaim.date > insuranceContract.insuranceStartDate &&
                discountClaim.date > (lastPayOutDate + 23 hours + 59 minutes) &&
                discountClaim.steps >= dailyStepLimit;

            if (isValid) {
                validClaims++;
                lastPayOutDate = discountClaim.date;
            }
        }
        uint dailyDiscount = (insuranceContract.paidPremiumInWei /
            discountFraction) / 365;
        uint payoutAmount = dailyDiscount * validClaims;

        contracts[msg.sender].lastPayOutDate = lastPayOutDate;
        payable(msg.sender).transfer(payoutAmount);
    }

    function processClaim(InsuranceClaim calldata claim) external onlyOwner {
        require(
            claim.admissionDate < claim.releaseDate,
            "Releasedate is before Admissiondate"
        );
        require(
            claim.releaseDate < block.timestamp,
            "No ongoing hospitalisation."
        );
        address policyHolderAdress = policyHolder[claim.policyId];
        InsuranceContract memory insuranceContract = contracts[
            policyHolderAdress
        ];
        require(
            insuranceContract.policyId != 0,
            "There is no insured person with the given policyId"
        );
        require(
            claim.admissionDate > insuranceContract.insuranceStartDate,
            "No claims before insurance start date"
        );
        require(
            claim.admissionDate < insuranceContract.insuranceEndDate,
            "No claims after insurance ends"
        );

        uint claimEndDate = claim.releaseDate >
            insuranceContract.insuranceEndDate
            ? insuranceContract.insuranceEndDate
            : claim.releaseDate;
        uint durationOfStay = claimEndDate - claim.admissionDate;
        uint daysOfStay = durationOfStay / 1 days;
        uint payoutAmount = daysOfStay *
            insuranceContract.dailyHospitalCashInWei;

        emit NewPayout(
            claim.policyId,
            claim.admissionDate,
            claimEndDate,
            payoutAmount
        );
        payable(msg.sender).transfer(payoutAmount);
    }
}
