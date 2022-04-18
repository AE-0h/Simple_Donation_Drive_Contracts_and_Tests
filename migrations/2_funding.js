const Funding = artifacts.require('Funding');
const SECONDS_IN_HOUR = 3600;
const HOURS_IN_A_DAY =24;

const DAY = SECONDS_IN_HOUR * HOURS_IN_A_DAY;

const Goal = 10**15;

module.exports = function(deployer){
    deployer.deploy(Funding, DAY, Goal);
};
