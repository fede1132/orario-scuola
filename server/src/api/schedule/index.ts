import { Router } from "express"
import { db } from "../.."
import auth from "../../auth"
import axios from "axios"
import { scrape } from "../../scraper"
import { epochTime } from "../../util/epoch"


class Schedule {
    router: Router = Router()
    types = ["Classi", "Docenti", "Aule"]

    constructor() {

        this.router.get('/updateSchedule', auth, async (req, res) => {
            let url: string | undefined = <string | undefined>req.query.url
            let token: string | undefined = <string | undefined>req.query.token
            if (url===undefined) {
                res.status(400).send({success:false, code:"url.not-present"})
                return
            }
            if (!db.isAdmin(token!)) {
                res.status(403).send({success:false, code:"token.not-admin"})
                return
            }
            if (url.endsWith("index.html")) {
                url = url.substr(0, url.indexOf("index.html"))
            }
            db.updateScheduleUrl(url)
            res.status(200).send({success: true, code:"schedule.updated"})
        })

        this.router.get('/getSchedule/:type/:value', auth, async (req, res) => {
            let route = req.url.substr(0, req.url.indexOf("?"))
            //let cache = db.getCache(route)
            let cache: any = undefined
            if (cache !== undefined && cache.time+parseInt(process.env.CACHE_TIME!) < epochTime()) {
                res.status(200).send({success: true, cache: true, code: "schedule.received", data: JSON.parse(cache.content)})
                return
            }
            let type: string | undefined = <string | undefined>req.params.type
            let value: string | undefined = <string | undefined>req.params.value
            if (type === undefined || parseInt(type) >= this.types.length) {
                res.status(400).send({success:false, code:"type.invalid"})
                return
            }
            if (value === undefined) {
                res.status(400).send({success:false, code:"value.invalid"})
                return
            }
            const response = await axios.get(`${db.getScheduleUrl()}/${this.types[parseInt(type)]}/${value}${value.endsWith(".html")?"":".html"}`)
            const scraped = await scrape(response.data)
            db.updateCache(route, JSON.stringify(scraped))
            res.status(200).send({success: true, cache: false, code: "schedule.received", data: scraped})
        })

    }

}

export default Schedule
