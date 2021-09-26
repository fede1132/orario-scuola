import Data from './data'
import Lesson from './lesson'

export async function scrape(html: string) {
    console.log(typeof html)
    const data = new Data(html.replace("&nbsp;", "").replace(/^\s*\n/gm, "").split(/\r?\n/))
    // raw data
    let hours = []
    let defaultColspan = 1
    let unsorted = []

    let line = data.nextLine()
    let row = 0
    // skip the table head
    while (row < 2) {
        line = data.nextLine()
        if (line.startsWith("<TR")) row++
    }
    row = 0
    // start the loop
    while (true) {
        line = data.nextLine() 
        // tr = new row
        if (line.includes("TR")) {
            if (line.startsWith("<TR")) row++
            continue
        }
        let next = data.nextLine()
        // end of the table
        if (line === "</TABLE>" && next === "</CENTER>") break
        // skip empty cells
        if (line.startsWith('<TD') && next === '</TD>') continue
        // filter hours (ex. 8.00, 9.00)
        if (line === "<TD class = 'mathema' NOWRAP>") {
            hours.push(next)
            data.nextLine()
            continue
        }

        // rowspan = lessons row
        if (line.includes("ROWSPAN")) {
            // cell settings
            let colspan = parseInt(line.substr(line.indexOf("COLSPAN=")+8, 1))
            if (defaultColspan<colspan) defaultColspan = colspan
            let rowspan = parseInt(line.substr(line.indexOf("ROWSPAN=")+8, 1))
            let lesson: Lesson = {
                colspan: colspan,
                rowspan: rowspan,
                teachers: []
            }
            let lessonData = [
                cleanString(next) // lesson name
            ]
            line = data.nextLine()
            // get contents of the cell
            while (line !== "</TD>") {
                if (!line.includes("&nbsp;")) lessonData.push(cleanString(line))
                line = data.nextLine() // teachers & room
            }
            if (lessonData.length===1) {
                unsorted[row].push({
                    colspan: 1,
                    rowspan: 1,
                    empty: true
                })
                continue
            }
            // format cell data into an object
            lesson.name = lessonData[0]
            for (let i=1;i<lessonData.length-1;i++) {
                lesson.teachers?.push(lessonData[i])
            }
            // if the lesson name contains "VIDEOLEZIONE" there is no room
            if (!lessonData[0].includes("VIDEOLEZIONE")) lesson.room = lessonData[lessonData.length-1]
            else lesson.teachers?.push(lessonData[lessonData.length-1])

            // push the result to an array to be sorted
            if (unsorted[row] === undefined) unsorted[row] = [lesson]
            else unsorted[row].push(lesson)
        }
    }

    // now sort the lessons

    let sorted: any = {
    }
    // fill the array with empty cells, the numbers of cells will be the result of hours.length * 6 (days of the school week)
    for (let hour in hours) {
        let row = [
            [],
            [],
            [],
            [],
            [],
            []
        ]
        sorted[hours[hour]] = row
    }
    
    let day = 0
    // iterate over the hours
    for (let str in hours) {
        day = 0
        let hour = parseInt(str)
        // iterate over the unsorted lessons
        for (let index in unsorted[hour]) {
            let lesson = unsorted[hour][index]
            for (let i=0;i<lesson.rowspan;i++) {
                for (let j=0;j<Math.floor(defaultColspan/lesson.colspan);j++) {
                    sorted[hours[hour+i]][day].push(lesson)
                }
            }
            // scan for the next empty day
            while (sorted[hours[hour]][day].length !== 0) {
                day++
                if (day>5) {
                    day = 5
                    break
                }
            }
        }
    }

    return sorted

}

// clean the content from html tags
function cleanString(line: string): string {
    if (line.includes("href")) {
        line = line.substr(22, line.length-22)
        return line.substr(line.indexOf(">")+1, (line.indexOf("<")-line.indexOf(">"))-1)
    }
    line = line.substr(1, line.length-1)
    return line.substr(line.indexOf(">")+1, (line.indexOf("<")-line.indexOf(">"))-1)
}


