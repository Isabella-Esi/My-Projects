import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';

const WalletCard = () => {
    const [errorMessage, setErrorMessage] = useState(null);
    const [defaultAccount, setDefaultAccount] = useState(null);
    const [userBalance, setUserBalance] = useState(null);
    const [connectButtonText, setConnectButtonText] = useState('Connect Wallet');

    useEffect(() => {
        const handleAccountsChanged = (accounts) => {
            accountChangeHandler(accounts[0]);
        };

        const handleChainChanged = () => {
            window.location.reload();
        };

        if (window.ethereum) {
            window.ethereum.on('accountsChanged', handleAccountsChanged);
            window.ethereum.on('chainChanged', handleChainChanged);

            return () => {
                window.ethereum.off('accountsChanged', handleAccountsChanged);
                window.ethereum.off('chainChanged', handleChainChanged);
            };
        }
    }, []);

    const connectWalletHandler = () => {
        if (window.ethereum) {
            window.ethereum
                .request({ method: 'eth_requestAccounts' })
                .then((result) => {
                    accountChangeHandler(result[0]);
                })
                .catch((error) => {
                    console.error('Failed to connect wallet:', error);
                    setErrorMessage('Failed to connect wallet');
                });
        } else {
            setErrorMessage('Install MetaMask');
        }
    };

    const accountChangeHandler = (newAccount) => {
        setDefaultAccount(newAccount);
        getUserBalance(newAccount);
    };

    const getUserBalance = (address) => {
        window.ethereum
            .request({ method: 'eth_getBalance', params: [address, 'latest'] })
            .then((balance) => {
                setUserBalance(ethers.formatEther(balance));
            })
            .catch((error) => {
                console.error('Failed to fetch balance:', error);
                setUserBalance(null);
                setErrorMessage('Failed to fetch balance');
            });
    };

    return (
        <div className='walletCard'>
            <h4>Connection to Evie's MetaMask using window.ethereum methods</h4>
            <button onClick={connectWalletHandler}>{connectButtonText}</button>
            <div className='accountDisplay'>
                <h3>Address: {defaultAccount}</h3>
            </div>
            <div className='balanceDisplay'>
                <h3>Balance: {userBalance}</h3>
            </div>
            {errorMessage && <p>{errorMessage}</p>}
        </div>
    );
};

export default WalletCard;
