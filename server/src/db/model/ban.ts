class Ban {
    type: number | undefined // 0 = http ban 1 = mail ban
    id: string | undefined
    time: number | undefined
    unban: number | undefined
    constructor(type: number | undefined, id: string | undefined = undefined, time: number | undefined = undefined, unban: number | undefined = undefined) {
        this.id = id
        this.time = time
        this.unban = unban
    }
}

export default Ban
