#import "utils.typ"

// set rules
#let setrules(uservars, doc) = {
    set heading(numbering: "1")

    set text(
        font: uservars.bodyfont,
        size: uservars.fontsize,
        hyphenate: false,
    )

    set list(
        spacing: uservars.linespacing
    )

    set par(
        leading: uservars.linespacing,
        justify: true,
    )

    doc
}

// show rules
#let showrules(uservars, doc) = {
    // name title
    show heading.where(
        level: 1,
    ): it => block(width: 100%)[
        #set text(font: uservars.headingfont, size: 1.4em, weight: "bold")
        #if (uservars.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(4pt)
    ]

    // uppercase section headings
    show heading.where(
        level: 2,
    ): it => block(width: 100%)[
        #set align(left)
        #set text(font: uservars.headingfont, weight: "bold")
        #if (uservars.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(-0.95em) #line(length: 100%, stroke: 0.5pt + black) // draw a line
    ]

    show heading.where(
        level: 3,
    ): it => block(width: 100%)[
        #set text(font: uservars.headingfont, size: 1.16em, weight: "regular")
        #it.body
    ]

    show link: it => [
        #set underline(
            offset: 0.15em,
            stroke: (paint: rgb("#475C73"), thickness: 0.1em, dash: "dotted")
        )
        #underline(it)
    ]

    doc
}

// set page layout
#let cvinit(doc) = {
    doc = setrules(doc)
    doc = showrules(doc)

    doc
}

#let contacttext(info, uservars) = block(width: 100%)[
    #let profiles = (
        box(link("mailto:" + info.personal.email)),
    ).filter(it => it != none) // filter out none elements from the profile array

    #if info.personal.profiles.len() > 0 {
        for profile in info.personal.profiles {
            profiles.push(
                box(link(profile.url)[#profile.url.split("//").at(1)])
            )
        }
    }

    #set text(font: uservars.bodyfont, size: uservars.fontsize * 1)
    #pad(x: 0em)[
        #profiles.join([#sym.space.en #sym.diamond.filled #sym.space.en])
    ]
    #v(4pt)
]

#let cvheading(info, uservars) = {
    align(center)[
        = #info.personal.name
        #contacttext(info, uservars)
    ]
}

#let cvwork(info, isbreakable: true) = {
    if info.work != none {block[
        == Work Experience <work>
        #for w in info.work {
            block(width: 100%, breakable: isbreakable)[
                // line 1: company and location
                #if w.url != none [
                    === #link(w.url)[#w.organization] #utils.ref-label(w.organization,"") #h(1fr) #w.location \
                ] else [
                    === #w.organization #utils.ref-label(w.organization, "") #h(1fr) #w.location \
                ]
            ]
            // create a block layout for each work entry
            let index = 0
            for p in w.positions {
                v(0.2em)
                block(width: 100%, breakable: isbreakable, above: 0.8em)[
                    // parse ISO date strings into datetime objects
                    #let start = utils.strpdate(p.startDate)
                    #let end = utils.strpdate(p.endDate)
                    // line 2: position and date range
                    #text(size: 1.07em, style: "italic")[
                        #p.position
                        #h(1fr)
                        #start #sym.dash.en #end
                    ]\

                    #utils.ref-label(w.organization, p.position)

                    // highlights or description
                    #for hi in p.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                ]
                index = index + 1
            }
        }
    ]}
}

#let cveducation(info, isbreakable: true) = {
    if info.education != none {block[
        == Education <edu>
        #for edu in info.education {
            let start = utils.strpdate(edu.startDate)
            let end = utils.strpdate(edu.endDate)

            let edu-items = ""
            if edu.honors != none {edu-items = edu-items + "- *Honors*: " + edu.honors.join(", ") + "\n"}
            if edu.courses != none {edu-items = edu-items + "- *Courses*: " + edu.courses.join(", ") + "\n"}
            if edu.highlights != none {
                for hi in edu.highlights {
                    edu-items = edu-items + "- " + hi + "\n"
                }
                edu-items = edu-items.trim("\n")
            }

            // create a block layout for each education entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: institution and location
                #if edu.url != none [
                    === #link(edu.url)[#edu.institution] #h(1fr) #edu.location \
                ] else [
                    === #edu.institution #h(1fr) #edu.location \
                ]
                // line 2: degree and date
                #underline(text(style: "italic")[
                    #edu.studyType in #edu.area
                    #h(1fr)
                    #start #sym.dash.en #end
                ]) \
                #eval(edu-items, mode: "markup")
            ]
        }
    ]}
}

#let cvaffiliations(info, isbreakable: true) = {
    if info.affiliations != none {block[
        == Leadership & Activities <lead>
        #for org in info.affiliations {
            // parse ISO date strings into datetime objects
            let start = utils.strpdate(org.startDate)
            let end = utils.strpdate(org.endDate)

            // create a block layout for each affiliation entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: organization and location
                #if org.url != none [
                    === #link(org.url)[#org.organization] #h(1fr) #org.location \
                ] else [
                    === #org.organization #h(1fr) #org.location \
                ]
                // line 2: position and date
                #underline(text(style: "italic")[
                    #org.position
                    #h(1fr)
                    #start #sym.dash.en #end
                ]) \
                // highlights or description
                #if org.highlights != none {
                    for hi in org.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                } else {}
            ]
        }
    ]}
}

#let cvprojects(info, isbreakable: true) = {
    if info.projects != none {block[
        == Projects <proj>
        #for project in info.projects {
            // parse ISO date strings into datetime objects
            let start = utils.strpdate(project.startDate)
            let end = utils.strpdate(project.endDate)
            // create a block layout for each project entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: project name
                #if project.url != none [
                    === #link(project.url)[#project.name] \
                ] else [
                    === #project.name \
                ]
                // line 2: organization and date
                #underline(text(style: "italic")[
                    #project.affiliation
                    #h(1fr)
                    #start #sym.dash.en #end
                ])\
                // summary or description
                #for hi in project.highlights [
                    - #eval(hi, mode: "markup")
                ]
            ]
        }
    ]}
}

#let cvawards(info, isbreakable: true) = {
    if info.awards != none {block[
        == Honors & Awards <awards>
        #for award in info.awards {
            // parse ISO date strings into datetime objects
            let date = utils.strpdate(award.date)
            // create a block layout for each award entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: award title and location
                #if award.url != none [
                    === #link(award.url)[#award.title] #h(1fr) #award.location \
                ] else [
                    === award.title #h(1fr) #award.location \
                ]
                // line 2: issuer and date
                #underline([
                    Issued by #text(style: "italic")[#award.issuer]
                    #h(1fr)
                    #date
                ]) \
                // summary or description
                #if award.highlights != none {
                    for hi in award.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                } else {}
            ]
        }
    ]}
}

#let cvcertificates(info, isbreakable: true) = {
    if info.certificates != none {block[
        == Licenses & Certifications <certs>

        #for cert in info.certificates {
            // parse ISO date strings into datetime objects
            let date = utils.strpdate(cert.date)
            // create a block layout for each certificate entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: certificate name
                #if cert.url != none [
                    === #link(cert.url)[#cert.name] \
                ] else [
                    === #cert.name \
                ]
                // line 2: issuer and date
                #underline([
                    Issued by #text(style: "italic")[#cert.issuer]
                    #h(1fr)
                    #date
                ]) \
            ]
        }
    ]}
}

#let cvpublications(info, isbreakable: true) = {
    if info.publications != none {block[
        == Research & Publications <pubs>
        #for pub in info.publications {
            // parse ISO date strings into datetime objects
            let date = utils.strpdate(pub.releaseDate)
            // create a block layout for each publication entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: publication title
                #if pub.url != none [
                    === #link(pub.url)[#pub.name] \
                ] else [
                    === #pub.name \
                ]
                // line 2: publisher and date
                #underline([
                    Published on #text(style: "italic")[#pub.publisher]
                    #h(1fr)
                    #date
                ]) \
            ]
        }
    ]}
}

#let cvskills(info, isbreakable: true) = {
    if (info.languages != none) or (info.skills != none) or (info.interests != none) {block(breakable: isbreakable)[
        == Skills, Languages, Interests <skills>
        #if (info.languages != none) [
            #let langs = ()
            #for lang in info.languages {
                langs.push([#lang.language (#lang.fluency)])
            }
            - *Languages*: #langs.join(", ")
        ]
        #if (info.skills != none) [
            #for group in info.skills [
                - *#group.category*: #group.skills.join(", ")
            ]
        ]
        #if (info.interests != none) [
            - *Interests*: #info.interests.join(", ")
        ]
    ]}
}

#let cvreferences(info, isbreakable: true) = {
    if info.references != none {block[
        == References <refs>
        #for ref in info.references {
            block(width: 100%, breakable: isbreakable)[
                #if ref.url != none [
                    - *#link(ref.url)[#ref.name]*: "#ref.reference"
                ] else [
                    - *#ref.name*: "#ref.reference"
                ]
            ]
        }
    ]} else {}
}

#let endnote() = {
    place(
        right,
        dy: -0.6em,
        block[
            #set text(size: 8pt, font: "Consolas")
            Updated on #datetime.today().display("[year]-[month]-[day]") with #strike[LaTeX] *#link("https://typst.app")[Typst]*
        ]
    )
}
