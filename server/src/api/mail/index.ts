import { Router } from "express"
import { db, fail2ban, mail } from "../../"
import { genCode } from "../../util/generator"

class Mail {
    router: Router = Router()
    constructor() {

        this.router.get('/send', async (req, res) => {
            let email = req.query.email?.toString()
            if (email===undefined) {
                res.status(400).send({success: false, code: "email.invalid"})
                return
            }
            if ((await fail2ban.isMailBanned(email))) {
                res.status(403).send({success: false, code: "banned.email"})
                return
            }
            let code = genCode()
            console.log(`Code: ${code}`)
            //await mail.sendCode("fendt873@gmail.com", code);
            db.newMail(email, code)
            res.status(200).send({success: true, code: "email.sent"})
        })

    }
}

export default Mail
