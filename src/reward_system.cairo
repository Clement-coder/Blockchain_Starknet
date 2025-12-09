#[starknet::contract]
mod RewardSystem {
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        owner: ContractAddress,
        balances: LegacyMap<ContractAddress, u256>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    struct PointsAdded {
        user: ContractAddress,
        amount: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    struct PointsRedeemed {
        user: ContractAddress,
        amount: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
    }

    fn assert_only_owner(self: @ContractState) {
        let caller = get_caller_address();
        let owner = self.owner.read();
        assert(caller == owner, 'Not owner');
    }

    #[external(v0)]
    fn add_points(
        ref self: ContractState,
        user: ContractAddress,
        amount: u256
    ) {
        self.assert_only_owner();
        assert(amount > 0, 'Invalid amount');

        let balance = self.balances.read(user);
        self.balances.write(user, balance + amount);

        self.emit(PointsAdded { user, amount });
    }

    #[external(v0)]
    fn redeem_points(
        ref self: ContractState,
        amount: u256
    ) {
        assert(amount > 0, 'Invalid amount');

        let caller = get_caller_address();
        let balance = self.balances.read(caller);

        assert(balance >= amount, 'Insufficient balance');

        self.balances.write(caller, balance - amount);

        self.emit(PointsRedeemed { user: caller, amount });
    }

    #[external(v0)]
    fn get_balance(self: @ContractState, user: ContractAddress) -> u256 {
        self.balances.read(user)
    }

    #[external(v0)]
    fn get_owner(self: @ContractState) -> ContractAddress {
        self.owner.read()
    }
}