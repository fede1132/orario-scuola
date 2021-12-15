import { genToken } from "../util/generator"
import { epochTime } from "../util/epoch"

import Ban from "./model/ban"
import Mail from "./model/mail"
import CachedRoute from "./model/cache"
import Setting from "./model/setting"

class Database {
    private db
    constructor() {
        this.db = require('better-sqlite3')('database.db')
        try {
            this.db.prepare('CREATE TABLE IF NOT EXISTS settings ( `key` TEXT, `value` TEXT)').run()
            this.db.prepare('CREATE TABLE IF NOT EXISTS users ( `email` TEXT, `token` TEXT, `admin` BOOL)').run()
            this.db.prepare('CREATE TABLE IF NOT EXISTS fail2ban ( `type` INTEGER, `id` TEXT, `time` INTEGER, `unban` INTEGER)').run()
            this.db.prepare('CREATE TABLE IF NOT EXISTS mails (`email` TEXT, `time` INTEGER, `code` INTEGER)').run()
            this.db.prepare('CREATE TABLE IF NOT EXISTS cache (`route` TEXT, `time` INTEGER, `content` TEXT)').run()
            console.log("🔥 Database is running.")
        } catch (e) {
            if (e) console.log(`❌ Got an error while trying to use sqlite3 storage! Error:\n${e}`)
        }
    }

    // Settings methods

    getScheduleUrl(): Setting | undefined {
        let row = this.db.prepare('SELECT * FROM settings WHERE key = \'schedule_url\'').get()
        if (row===undefined) return undefined
        return new Setting(row.key, JSON.parse(row.value))
    }

    updateScheduleUrl(url: string): void {
        if (this.getScheduleUrl()===undefined) {
            this.db.prepare("INSERT INTO settings (key, value) VALUES ('schedule_url', ?)").run(JSON.stringify({url: url, time: epochTime()}))
            return
        }
        this.db.prepare("UPDATE settings SET value = ? WHERE key = \'schedule_url\'").run(JSON.stringify({url: url, time: epochTime()}))
    }

    // Token methods

    validToken(token: string): boolean {
        const row = this.db.prepare("SELECT * FROM users WHERE `token` = ?").get(encodeURIComponent(token))
        if (row === undefined) return false;
        return true;
    }

    getToken(email: string): object {
        const row = this.db.prepare("SELECT * FROM users WHERE `email` = ?").get(encodeURIComponent(email))
        const token = genToken()
        this.db.prepare(
            row===undefined ?
            "INSERT INTO users (token, email) VALUES (?, ?)" :
            "UPDATE users SET token = ? WHERE `email` = ?"
        ).run(encodeURIComponent(token), encodeURIComponent(email))
        return {
            token,
            admin: row.admin
        }
    }

    isAdmin(token: string): boolean | undefined {
        const row = this.db.prepare("SELECT admin FROM users WHERE token = ?").get(encodeURIComponent(token))
        if (row===undefined) return undefined
        return row.admin === 1 ? true : false
    }

    // Fail2Ban methods

    getBans(type: number, id: string) {
        let rows = this.db.prepare("SELECT * FROM fail2ban WHERE type = ? AND id = ?").get(type, id)
        let bans: Ban[] = []
        rows.forEach((row: any) => {
            let ban = new Ban(row.id)
            Object.assign(ban, row)
            bans.push(ban)
        })
        return bans
    }
    
    isBanned(type: number, id: string): Ban | undefined {
        let row = this.db.prepare("SELECT * FROM fail2ban WHERE type = ? AND id = ? AND unban > ?").get(type, id, epochTime())
        if (row === undefined) return undefined
        let ban = new Ban(row.id)
        Object.assign(ban, row)
        return ban
    }

    addBan(type: number, id: string, unban: number) {
        this.db.prepare("INSERT INTO fail2ban (type, id, time, unban) VALUES (?, ?, ?, ?)").run(type, id, epochTime(), unban)
    }

    // Mail methods

    getMails(email: string): Mail[] | undefined {
        let rows = this.db.prepare("SELECT * FROM mails WHERE email = ?").all(encodeURIComponent(email))
        if (rows === undefined) return rows
        let mails: Mail[] = []
        for (let i in rows) {
            let row = rows[i]
            let mail = new Mail(row.email, row.time)
            mails.push(mail)
        }
        return mails
    }

    newMail(email: string, code: number) {
        if (this.getMails(email) !== undefined) {
            this.db.prepare("UPDATE mails SET code = null WHERE email = ? AND code NOT null").run(encodeURIComponent(email))
        }
        this.db.prepare("INSERT INTO mails (email, time, code) VALUES (?, ?, ?)").run(encodeURIComponent(email), epochTime(), code)
    }

    getMailCode(email: string): number | undefined {
        let row = this.db.prepare("SELECT code FROM mails WHERE email = ? AND code NOT null").get(encodeURIComponent(email))
        return row?.code
    }

    // Cache methods
    getCache(route: string): CachedRoute | undefined {
        let row = this.db.prepare("SELECT * FROM cache WHERE route = ?").get(encodeURIComponent(route))
        if (row === undefined) return undefined
        return new CachedRoute(row.route, row.time, row.content)
    }

    updateCache(route: string, content: string) {
        if (this.getCache(route)===undefined) {
            this.db.prepare("INSERT INTO cache (route, time, content) VALUES (?, ?, ?)").run(encodeURIComponent(route), epochTime(), content)
            return
        }
        this.db.prepare("UPDATE cache SET content = ?, time = ? WHERE route = ?").run(content.toString(), epochTime(), route)
    }

    // Panic
    panicClean() {
        if (process.env.PANIC) {
            this.db.prepare("DROP TABLE settings").run()
            this.db.prepare("DROP TABLE users").run()
            this.db.prepare("DROP TABLE fail2ban").run()
            this.db.prepare("DROP TABLE mails").run()
            this.db.prepare("DROP TABLE cache").run()
        }
    }

}

export default Database
