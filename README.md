# Stuff to do I guess

write some gd tests

1. remember how I intended for this to work
2. upgrade from aura to lwc
3. refactor - maybe try leveraging some packages?
4. update from process builder to flow
5. try out automated testing framework(s)
6. make it easier to add/remove users
7. data model enhancements
   a. make 'restaurant' data less vague
   i. maybe there's an api out there with restaurant data
   b. is there any other information that users would like to know?
8. decider enhancements
   a. make it easier to select users
   b. figure out a layout that looks...not terrible
   c. redo 'suggestion's - additive, rather than either/or
   d. update filtering (match data model enhancement)
9. maybe google maps integration if it's free

# ======================================================
start from scratch

keep old data to hold preferred restaurants and such

documenu api for restaurant data
   figure out how to get this working
      documenu-npm library in lwc
LunchPicker app
   LunchPicker LWC
      table with restaurant data
         clicking restaurant name / button in table adds restaurant to pool to be selected
      sort by:
         location (allows state, zip, geo, geobox, distance from)
         preferred
         cost
   Calendar records restaurants visited, time, date, who went
