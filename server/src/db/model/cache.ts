class CachedRoute {
    route: string
    time: number
    content: string
    constructor(route: string, time: number, content: string) {
        this.route = route
        this.time = time
        this.content = content
    }
}

export default CachedRoute
