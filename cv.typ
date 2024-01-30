#import "cv-base.typ": *

#let cvdata = yaml("nuke.yml")

#let uservars = (
    headingfont: "Fira Sans",
    bodyfont: "Sans",
    fontsize: 11pt, // 10pt, 11pt, 12pt
    linespacing: 6pt,
    headingsmallcaps: false
)

// setrules and showrules can be overridden by re-declaring it here
// #let setrules(doc) = {
//      // add custom document style rules here
//
//      doc
// }

#let customrules(doc) = {
    // add custom document style rules here
    set page(
        paper: "us-letter", // a4, us-letter
        margin: 1cm,
        footer: [
            #set align(center)
            #set text(0.8em)
            #counter(page).display(
                "1/1",
                both: true,
            )
            #endnote()
        ]
    )

    doc
}

#let cvinit(doc) = {
    doc = setrules(uservars, doc)
    doc = showrules(uservars, doc)
    doc = customrules(doc)

    doc
}

// each section body can be overridden by re-declaring it here
// #let cveducation = []

// ========================================================================== //

#show: doc => cvinit(doc)

#cvheading(cvdata, uservars)
#cvwork(cvdata)
#pagebreak()
#cveducation(cvdata)
#cvaffiliations(cvdata)
#cvprojects(cvdata)
#cvawards(cvdata)
#cvcertificates(cvdata)
// #cvpublications(cvdata)
#cvskills(cvdata)
