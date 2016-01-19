{inspect} = require 'util'
fs        = require 'fs'
parse     = require 'xml-parser'

xml  = fs.readFileSync process.argv[2], 'utf-8'
data = parse xml

if data.root?.name != 'compendium'
    console.log 'Parsed document isn\'t compendium'
    process.exit 1

data = data.root?.children

unless data?.length > 0
    console.log 'Parsed document doesn\'t contain data'
    process.exit 1

counter = 0

Spells  = []
Classes = {}
Fields  = ['name','level','school','time','ritual','range','duration','components']

parse_spell = (data) ->
    spell = {}

    for entry in data
        # console.log inspect entry
        # console.log '------'
        switch entry?.name
            when 'name', 'level', 'school', 'time', 'range', 'duration', 'components'
                spell[entry.name] = entry.content
            when 'classes'
                for c in entry.content.split /\s*,\s*/
                    Classes[c] = 1
                    spell[c] = 1
            # when 'components'
            #     for m in entry.content.match /[VSM](?=,|\s+\(|\s*$)/g
            #         spell[m] = 1
            when 'ritual'
                spell.ritual = 1

    return spell

for entry in data
    continue if entry?.name != 'spell'

    Spells.push parse_spell(entry.children)

Classes = Object.keys(Classes).sort()
# console.log inspect Spells, depth:null
# console.log inspect Classes, depth:null

spell2str = (spell) ->
    res = []
    res.push spell[f] or ' ' for f in Fields
    res.push spell[f] or ' ' for f in Classes
    return res.join(';')

Spells.sort (a,b) ->
    return 1 if a.level > b.level
    return -1 if a.level < b.level
    return 1 if a.name > b.name
    return -1 if a.name < b.name
    return 0


console.log "#{Fields.join(';')};#{Classes.join(';')}"
for spell in Spells
    console.log spell2str(spell)
