# Firestore indexes

`firebase/firestore.indexes.json` is **generated** — do not edit by hand:

```
node tool/gen_indexes.js
```

## What is generated

Listing search always filters `status == published`. The generator emits one composite index for every combination of:

* category state: none · `categoryId` · `categoryId + subcategoryId` (subcategory is only selectable after a category)
* `locationId` (on/off), `isFeatured` (on/off), `searchKeywords` array-contains (on/off)
* sort: `createdAt` desc · `createdAt` asc · `price` asc · `price` desc

→ 96 indexes. Price range filters reuse the `price`-ordered indexes.

Additional indexes: owner listings (`ownerId, createdAt desc` and `ownerId, status, createdAt desc`), conversations (`participantIds array-contains, lastMessageAt desc`), seller reviews (`sellerId, status, createdAt desc`), open reports (`status, createdAt desc`), message rate limiting (`senderId, createdAt desc` on `messages`). Total: 102 (Firestore's limit is 200 per database).

## Deploy

```
firebase deploy --only firestore:indexes --project <project-id>
```

Building indexes can take several minutes on a populated database. A query without an index fails with a link to create it — add the combination to `tool/gen_indexes.js` instead of clicking the link, so the file stays the source of truth.
