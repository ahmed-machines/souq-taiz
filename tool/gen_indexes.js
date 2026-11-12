// Generates firebase/firestore.indexes.json. Run: node tool/gen_indexes.js
// Listing search combines: category state x location x featured x keyword,
// each with 4 sort orders (the status equality is always present).
const fs = require('fs');

const catStates = [[], ['categoryId'], ['categoryId', 'subcategoryId']];
const orders = [
  [{ fieldPath: 'createdAt', order: 'DESCENDING' }],
  [{ fieldPath: 'createdAt', order: 'ASCENDING' }],
  [{ fieldPath: 'price', order: 'ASCENDING' }],
  [{ fieldPath: 'price', order: 'DESCENDING' }],
];

const indexes = [];
for (const cat of catStates) {
  for (const loc of [false, true]) {
    for (const feat of [false, true]) {
      for (const kw of [false, true]) {
        for (const ord of orders) {
          const fields = [{ fieldPath: 'status', order: 'ASCENDING' }];
          for (const c of cat) fields.push({ fieldPath: c, order: 'ASCENDING' });
          if (loc) fields.push({ fieldPath: 'locationId', order: 'ASCENDING' });
          if (feat) fields.push({ fieldPath: 'isFeatured', order: 'ASCENDING' });
          if (kw) fields.push({ fieldPath: 'searchKeywords', arrayConfig: 'CONTAINS' });
          fields.push(...ord);
          indexes.push({ collectionGroup: 'listings', queryScope: 'COLLECTION', fields });
        }
      }
    }
  }
}

const asc = (f) => ({ fieldPath: f, order: 'ASCENDING' });
const desc = (f) => ({ fieldPath: f, order: 'DESCENDING' });

// Seller dashboard / owner lists.
indexes.push({ collectionGroup: 'listings', queryScope: 'COLLECTION', fields: [asc('ownerId'), desc('createdAt')] });
indexes.push({ collectionGroup: 'listings', queryScope: 'COLLECTION', fields: [asc('ownerId'), asc('status'), desc('createdAt')] });
// Conversations of a user.
indexes.push({ collectionGroup: 'conversations', queryScope: 'COLLECTION', fields: [{ fieldPath: 'participantIds', arrayConfig: 'CONTAINS' }, desc('lastMessageAt')] });
// Reviews of a seller.
indexes.push({ collectionGroup: 'reviews', queryScope: 'COLLECTION', fields: [asc('sellerId'), asc('status'), desc('createdAt')] });
// Admin: open reports.
indexes.push({ collectionGroup: 'reports', queryScope: 'COLLECTION', fields: [asc('status'), desc('createdAt')] });
// Message rate limiting in Cloud Functions.
indexes.push({ collectionGroup: 'messages', queryScope: 'COLLECTION', fields: [asc('senderId'), desc('createdAt')] });

fs.writeFileSync('firebase/firestore.indexes.json', JSON.stringify({ indexes, fieldOverrides: [] }, null, 2) + '\n');
console.log(`${indexes.length} composite indexes written`);

