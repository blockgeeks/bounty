var Bounty = artifacts.require('BountyBG');
var expectThrow = require('./helpers.js');

// For each contract(), a new instance of contract is created
// to make test easier. Each it() inside contract will use the
// same contract instance and state of contract is maintained.
// The contract creator address defaults to accounts[0].

// Test initial values are all correct upon contract creation
contract('Initial values tests:', async (accounts) => {
    it('owner address is correct', async () => {
        let bounty = await Bounty.deployed();
        let owner = await bounty.owner.call();
        assert.equal(owner, accounts[0]);
    });

    it('min bounty amount is correct', async () => {
        let bounty = await Bounty.deployed();
        let minAmount = await bounty.minBountyAmount.call();
        assert.equal(minAmount.toNumber(), web3.toWei(10, 'finney'));
    });

    it('min fee amount is correct', async () => {
        let bounty = await Bounty.deployed();
        let fee = await bounty.bountyFee.call();
        assert.equal(fee.toNumber(), web3.toWei(2, 'finney'));
    });

    it('bounty duration is correct', async () => {
        let bounty = await Bounty.deployed();
        let duration = await bounty.bountyDuration.call();
        assert.equal(duration.toNumber(), 30*60*60); // 30 hour in seconds
    });
});

contract('Can not write to owner only tests:', async (accounts) => {
    it('try to change bounty amount', async ()=> {
        let bounty = await Bounty.deployed();
        // the input param don't matter, from accounts must not be owner
        let tx = bounty.setMinBountyAmount(10, {from: accounts[1]});
        await expectThrow(tx);
    });

    it('try to withdraw fee', async() => {
        let bounty = await Bounty.deployed();
        let tx = bounty.withdrawFee(10, {from: accounts[2]});
        await expectThrow(tx);
    });

    it('try to set bounty duration', async() => {
        let bounty = await Bounty.deployed();
        let tx = bounty.setBountyDuration(10, {from:accounts[1]});
        await expectThrow(tx);
    });

    it('try to destroy contract', async() => {
        let bounty = await Bounty.deployed();
        let tx = bounty.destroyContract(10, { from: accounts[1] });
        await expectThrow(tx);
    })
})



// Test cases:

// - Test Group: Test initial values are all correct upon contract creation
// - Test owner's address match deployer address
// - Test ..

// - Test Group: Bounty Creation
// - Test bounty creation and then access the fields to make sure values match


// - Test rewarding users before time expiration and after it (set it to 0)
// - Test rewarding multiple users (complex)

// - Test fee mechanism is correct
// - Draw more fee than earend; make sure fees earned are correct
// - ensure fee can not be more than balance and make sure fee can not be greater than bounty etc.
//

// - Test Group: owner only functions can not be accessed by unauthorized accounts
// - Test reward user must be done by owner

// - Test basic setter/getters do the right thing

