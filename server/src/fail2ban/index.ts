import { Request, Response, NextFunction } from "express"
import { db } from "../"
import { epochTime } from "../util/epoch"
import Ban from "../db/model/ban"
import Mail from "../db/model/mail"

class Fail2Ban {
    // HTTP ban
    private MAX_RPM = 60 // max rpm (requests per minute)
    private HTTP_BAN_CALC = 3600 // 3600 seconds (1 hour)

    // Mail ban
    private MAX_MPM = 2; // max mail per minute
    private MAIL_BAN_CALC = 60 // 60 seconds (1 minute)

    private requests: Record<string, number[]> = {}
    constructor() {
        console.log("🔥 Fail2Ban running.")

        // clear loop to keep the memory clean
        // runs every 60 seconds
        setInterval(() => {
            let time = epochTime()-60
            for (let key in this.requests) {
                let requests = this.requests[key]
                let index: number | undefined
                let count: number = 0
                for (let i=0;i<requests.length;i++) {
                    if (requests[i] < time) {
                        if (index === undefined) index = i
                        count++
                    }
                }
                for (let i=0;i<count;i++) {
                    delete this.requests[key][index!]
                }
            }
        }, 60000)
    }

    // HTTP fail2ban system

    logRequest(ip: string): Ban | undefined {
        let ban = db.isBanned(0, ip)
        if (ban !== undefined) return ban
        if (this.requests[ip] === undefined) this.requests[ip] = []
        this.requests[ip].push(epochTime())
        const time = epochTime()-60
        let requests = 0
        for (let i=0;i<this.requests[ip].length;i++) {
            let request = this.requests[ip][i]
            if (request > time) requests++
        }
        if (requests >= this.MAX_RPM) {
            let unban = time+60+this.HTTP_BAN_CALC
            db.addBan(0, ip, unban)
            return new Ban(0, ip, time+60, unban)
        }
        return undefined
    }

    // express middleware
    async middleware(req: Request, res: Response, next: NextFunction) {
        var ip: string = req.headers['x-forwarded-for']?.toString() || (req.socket?.remoteAddress === undefined ? "null" : req.socket?.remoteAddress)
        const { fail2ban } = require('../')
        let result: Ban | undefined = fail2ban.logRequest(ip)
        if (result !== undefined) {
            res.status(403).json({success: false, code: "banned.http", unban: result.unban})
            return
        }
        next()
    }

    // Mail fail2ban system

    async isMailBanned(email: string): Promise<boolean> {
        if (db.isBanned(1, email)) return true
        const mails: Mail[] | undefined = db.getMails(email)
        if (mails===undefined) return false
        let time = epochTime()-60
        let count = 0
        for (let mail in mails) {
            if (mails[mail].time! > time) count++
        }
        if (count >= this.MAX_MPM) {
            db.addBan(1, email, time+60+this.MAIL_BAN_CALC)
            return true
        }
        return false
    }

}

export default Fail2Ban