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
        #set text(font: uservars.headingfont, size: 1.16em,  weight: "bold")
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
            offset: 0.18em,
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
            // create a block layout for each entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: company and location
                #if w.url != none [
                    === #link(w.url)[#w.organization] #utils.ref-label(w.organization,"") #h(1fr) #w.location
                ] else [
                    === #w.organization #utils.ref-label(w.organization, "") #h(1fr) #w.location
                ]

                #for p in w.positions {
                        let start = utils.strpdate(p.startDate)
                        let end = utils.strpdate(p.endDate)
                        underline(text(size: 1.07em, style: "italic")[
                            #p.position
                            #h(1fr)
                            #utils.ref-label(w.organization, p.position)
                            #start #sym.dash.en #end
                        ])
        
                        // highlights or description
                        for hi in p.highlights [
                            - #eval(hi, mode: "markup")
                        ]
                }
            ]
        }
    ]}
}

#let cveducation(info, isbreakable: true) = {
    if info.education != none {block[
        == Education <edu>
        #for i in info.education {
            block(width: 100%, breakable: isbreakable)[
                #if i.url != none [
                    === #link(i.url)[#i.institution] #utils.ref-label(i.institution,"") #h(1fr) #i.location
                ] else [
                    === #i.institution #utils.ref-label(i.institution, "") #h(1fr) #i.location
                ]

                #for d in i.degrees {
                        let start = utils.strpdate(d.startDate)
                        let end = utils.strpdate(d.endDate)
                        underline(text(size: 1.07em, style: "italic")[
                            #d.studyType in #d.degree
                            #h(1fr)
                            #utils.ref-label(i.institution, d.degree)
                            #start #sym.dash.en #end
                        ])

                        if d.highlights != none {
                            for hi in d.highlights [
                                - #eval(hi, mode: "markup")
                            ]
                        } else {}
                }
            ]
        }
    ]}
}

#let cvaffiliations(info, isbreakable: true) = {
    if info.affiliations != none {block[
        == Leadership & Activities <lead>
        #for org in info.affiliations {
            let start = utils.strpdate(org.startDate)
            let end = utils.strpdate(org.endDate)

            block(width: 100%, breakable: isbreakable)[
                #if org.url != none [
                    === #link(org.url)[#org.organization] #utils.ref-label(org.organization,"") #h(1fr) #org.location
                ] else [
                    === #org.organization #h(1fr) #org.location
                ]
                #underline(text(style: "italic")[
                    #org.position
                    #h(1fr)
                    #start #sym.dash.en #end
                ])

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
            let start = utils.strpdate(project.startDate)
            let end = utils.strpdate(project.endDate)
            block(width: 100%, breakable: isbreakable)[
                #if project.url != none [
                    === #link(project.url)[#project.name] #utils.ref-label(project.name,"")
                ] else [
                    === #eval(project.name, mode: "markup")
                ]
                #underline(text(style: "italic")[
                    #eval(project.affiliation, mode: "markup")
                    #h(1fr)
                    #start #sym.dash.en #end
                ])

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
            let date = utils.strpdate(award.date)
            block(width: 100%, breakable: isbreakable)[
                #if award.url != none [
                    === #link(award.url)[#award.title] #h(1fr) #award.location
                ] else [
                    === #award.title #h(1fr) #award.location
                ]
                #underline([
                    Issued by #text(style: "italic")[#award.issuer]
                    #h(1fr)
                    #date
                ])

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
            let date = utils.strpdate(cert.date)
            block(width: 100%, breakable: isbreakable)[
                #if cert.url != none [
                    === #link(cert.url)[#cert.name]
                ] else [
                    === #cert.name
                ]
                #underline([
                    Issued by #text(style: "italic")[#cert.issuer]
                    #h(1fr)
                    #date
                ])
            ]
        }
    ]}
}

#let cvpublications(info, isbreakable: true) = {
    if info.publications != none {block[
        == Research & Publications <pubs>
        #for pub in info.publications {
            let date = utils.strpdate(pub.releaseDate)
            block(width: 100%, breakable: isbreakable)[
                #if pub.url != none [
                    === #link(pub.url)[#pub.name]
                ] else [
                    === #pub.name
                ]
                #underline([
                    Published on #text(style: "italic")[#pub.publisher]
                    #h(1fr)
                    #date
                ])
            ]
        }
    ]}
}

#let cvskills(info, isbreakable: true) = {
    if (info.skills != none) or (info.interests != none) {block(breakable: isbreakable)[
        == Skills & Interests <skills>
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
