import { Router } from "express"
import { db } from "../.."
import auth from "../../auth"
import axios from "axios"
import { scrape, scrapeValues } from "../../scraper"
import { epochTime } from "../../util/epoch"
import { nextTick } from "process"


class Schedule {
    router: Router = Router()
    types = ["Classi", "Docenti", "Aule"]

    constructor() {

        this.router.post('/getUrl', auth, async (req, res) => {
            let token: string | undefined = <string | undefined>req.query.token
            if (!db.isAdmin(token!)) {
                res.status(403).send({success:false, code:"token.not-admin"})
                return
            }
            res.status(200).send({success: true, code:"schedule.updated", url: db.getScheduleUrl()?.value?.key})
        })

        this.router.post('/update', auth, async (req, res) => {
            let token: string | undefined = <string | undefined>req.query.token
            if (db.isAdmin(token!)) {
                let url: string | undefined = <string | undefined>req.query.url
                if (url !== undefined) {
                    if (url.endsWith("index.html")) {
                        url = url.substr(0, url.indexOf("index.html"))
                    }
                    if (url.endsWith("/")) {
                        url = url.substr(0, url.length-1)
                    }
                    db.updateScheduleUrl(url)
                    res.status(200).send({success: true, code:"schedule.updated"})
                    return
                }
            }
            res.status(200).send({success: true, code:"schedule.time.received", time: db.getScheduleUrl()?.value.time})
        })

        this.router.post('/getSchedule/:type/:value', auth, async (req, res, next) => {
            let route = req.url.substr(0, req.url.indexOf("?"))
            let cache = db.getCache(route)
            if (cache !== undefined && cache.time+parseInt(process.env.CACHE_TIME!) > epochTime()) {
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
            try {
                const response = await axios.get(`${db.getScheduleUrl()?.value?.url}/${this.types[parseInt(type)]}/${value}${value.endsWith(".html")?"":".html"}`);
                const scraped = await scrape(response?.data)
                db.updateCache(route, JSON.stringify(scraped))
                res.status(200).send({success: true, cache: false, code: "schedule.received", data: scraped})
            } catch (ex) {
                next(ex)
            }
        })

        this.router.post('/getValues', auth, async (req, res, next) => {
            let route = req.url.substr(0, req.url.indexOf("?"))
            let cache = db.getCache(route)
            if (cache !== undefined && cache.time+parseInt(process.env.CACHE_TIME!) > epochTime()) {
                res.status(200).send({success: true, cache: true, code: "schedule.received", data: JSON.parse(cache.content)})
                return
            }
            try {
                const response = await axios.get(`${db.getScheduleUrl()?.value?.url}`)
                const scraped = await scrapeValues(response.data)
                db.updateCache(route, JSON.stringify(scraped))
                res.status(200).send({success: true, cache: false, code: "schedule.received", data: scraped})
            } catch (ex) {
                next(ex)
            }
        })

    }

}

export default Schedule
