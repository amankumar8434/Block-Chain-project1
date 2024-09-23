module Charity::DonationPlatform {

    use aptos_framework::coin::{transfer, Coin};
    use aptos_framework::signer;
    use aptos_framework::aptos_account;
    use aptos_framework::aptos_coin::AptosCoin;

    struct UserDonationSetting has store, key {
        donation_percentage: u8, // Percentage of each transaction to donate (0-100)
        charity_address: address, // Address of the charity
    }

    // Function to set the donation percentage and charity address
    public fun set_donation_setting(account: &signer, charity_address: address, donation_percentage: u8) {
        assert!(donation_percentage <= 100, 1); // Ensure percentage is valid
        let user_address = signer::address_of(account);

        if (exists<UserDonationSetting>(user_address)) {
            move_to(account, UserDonationSetting { donation_percentage, charity_address });
        } else {
            let setting = UserDonationSetting { donation_percentage, charity_address };
            move_to(account, setting);
        }
    }

    // Function to process a transaction and automatically donate a portion
    public fun process_transaction(account: &signer, recipient: address, amount: u64) acquires UserDonationSetting {
        let user_address = signer::address_of(account);
        let donation_setting = borrow_global<UserDonationSetting>(user_address);
        let donation_amount = amount * (donation_setting.donation_percentage as u64) / 100;

        // Transfer the donation to the charity (AptosCoin)
        transfer<AptosCoin>(account, donation_setting.charity_address, donation_amount);

        // Transfer the remaining amount to the recipient (AptosCoin)
        let remaining_amount = amount - donation_amount;
        transfer<AptosCoin>(account, recipient, remaining_amount);
    }
}
