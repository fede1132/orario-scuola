import { Request, Response, NextFunction } from "express"
import { db } from './'

export default async (req: Request, res: Response, next: NextFunction) => {
    if (req.query.token === undefined) {
        res.status(401).json({success: false, code: "token.invalid"})
        return
    }
    var token: string = req.query.token.toString()
    if (token.length < parseInt(process.env.TOKEN_LENGTH!) || !db.validToken(token)) {
        res.status(401).json({success: false, code: "token.invalid"})
        return
    }
    next()
}
