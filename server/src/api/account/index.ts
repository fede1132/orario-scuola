import { Router } from "express"
import { db, fail2ban, mail } from "../../"
import { genCode } from "../../util/generator"
import auth from "../../auth"

class Account {
    router: Router = Router()
    constructor() {

        this.router.post('/login', async (req, res) => {
            let email = req.query.email?.toString()?.toLowerCase()?.trim()
            let code = parseInt(req.query?.code?.toString() ?? "")
            if (email === undefined || !email.endsWith('@gobettire.istruzioneer.it')) {
                res.status(400).send({success: false, code: "email.invalid"})
                return
            }
            if (isNaN(code)) {
                if ((await fail2ban.isMailBanned(email!))) {
                    res.status(403).send({success: false, code: "banned.email"})
                    return
                }
                let code = genCode()
                await mail.sendCode(email, code)
                db.newMail(email, code)
                res.status(200).send({success:true, code: "token.check-mail"})
                return
            }
            let mailCode = db.getMailCode(email!)
            if (mailCode === undefined) {
                res.status(400).send({success: false, code: "code.invalid"})
                return
            }
            if (mailCode !== code) {
                res.status(400).send({success: false, code: "code.invalid"})
                return
            }
            let token: any = db.getToken(email!)
            res.status(200).send({success: true, code: "token.received", token: token})
        })

        this.router.post('/panic', auth, (req,res) => {
            let token = req.query?.token?.toString()
            if (token && db.isAdmin(token)) {
                res.status(200).json({
                    success: true
                })
                process.env.PANIC = "true"
                db.panicClean()
            }
            res.status(401).json({
                success: false,
                code: "permission.denied"
            })
        })

    }
}

export default Account
