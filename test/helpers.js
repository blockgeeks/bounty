
// Helper function to help verify expected exceptions being thrown in tests
module.exports =  async (promise) => {
    try {
        await promise;
    } catch (err) {
        return;
    }
    assert(false, 'Expected throw not received');
}