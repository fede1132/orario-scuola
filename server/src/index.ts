import API from "./api"
import Database from "./db"
import Fail2Ban from "./fail2ban"
import Mail from "./mail"

// init dotenv
require('dotenv').config()

export const db = new Database()
export const mail = new Mail()
export const fail2ban = new Fail2Ban()

// load apis
new API()

// done
setTimeout(() => {
    console.log("\n👍 Everything is up and working.")
}, 1000);
