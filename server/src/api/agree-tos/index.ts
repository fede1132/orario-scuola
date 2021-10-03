import { Router } from "express"
import { db } from "../.."

class AgreeTOS {
    router: Router = Router()
    constructor() {
        this.router.get('/agree-tos', async (req, res) => {
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
            let token = db.getToken(email)
            res.status(200).send({success:true, code: "token.received", token: token})
        })
    }
}

export default AgreeTOS
