import { Router } from "express"
import { db, fail2ban, mail } from "../.."
import { genCode } from "../../util/generator"

class AgreeTOS {
    router: Router = Router()
    constructor() {
        this.router.post('/agree-tos', async (req, res) => {
            let email = req.query.email?.toString()
            let agree = req.query.agree?.toString()
            if (email === undefined || !email.includes("@") || !email.split("@")[0].includes(".") || !email.endsWith("@gobettire.istruzioneer.it")) {
                res.status(400).send({success: false, code: "email.invalid"})
                return
            }
            if (agree === undefined || agree !== "true") {
                res.status(400).send({success: false, code: "tos-agreement.invalid"})
                return
            }
            let token: any = db.getToken(email)
            if (token?.requireAuth) {
                if ((await fail2ban.isMailBanned(email))) {
                    res.status(403).send({success: false, code: "banned.email"})
                    return
                }
                let code = genCode()
                await mail.sendCode(email, code)
                db.newMail(email, code)
                res.status(200).send({success:true, code: "token.check-mail"})
                return
            }
            res.status(200).send({success:true, code: "token.received", token: token})
        })
    }
}

export default AgreeTOS
