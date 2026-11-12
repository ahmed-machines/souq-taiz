#!/usr/bin/env node
/**
 * tool/seed_firestore.js
 *
 * Seeds a fresh Firestore database with the initial categories, locations,
 * and an admin user placeholder for Souq Taiz.
 *
 * Usage:
 *   node tool/seed_firestore.js --project YOUR_PROJECT_ID
 *
 * Requirements:
 *   npm install -g firebase-tools
 *   firebase login
 */

'use strict';

const { initializeApp, cert, getApps } = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const path = require('path');
const fs = require('fs');

// ---------------------------------------------------------------------------
// Parse args
// ---------------------------------------------------------------------------
const args = process.argv.slice(2);
const projectFlag = args.indexOf('--project');
const projectId = projectFlag >= 0 ? args[projectFlag + 1] : process.env.GCLOUD_PROJECT;

if (!projectId) {
  console.error('Usage: node seed_firestore.js --project YOUR_PROJECT_ID');
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Initialize Admin SDK
// Look for a service account JSON in GOOGLE_APPLICATION_CREDENTIALS or
// fall back to Application Default Credentials (gcloud auth login).
// ---------------------------------------------------------------------------
if (!getApps().length) {
  const credPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (credPath && fs.existsSync(credPath)) {
    initializeApp({ credential: cert(credPath), projectId });
  } else {
    // ADC – works after: firebase login --reauth or gcloud auth application-default login
    const { applicationDefault } = require('firebase-admin/app');
    initializeApp({ credential: applicationDefault(), projectId });
  }
}

const db = getFirestore();
const now = Timestamp.now();

// ---------------------------------------------------------------------------
// Seed Data
// ---------------------------------------------------------------------------

/** @type {Array<{id: string, nameAr: string, nameEn: string, icon: string, order: number, subcategories: Array}>} */
const CATEGORIES = [
  {
    id: 'cars',
    nameAr: 'سيارات ومركبات',
    nameEn: 'Cars & Vehicles',
    icon: 'directions_car',
    order: 1,
    subcategories: [
      { id: 'cars_sedans', nameAr: 'سيارات سيدان', nameEn: 'Sedans' },
      { id: 'cars_suvs', nameAr: 'سيارات دفع رباعي', nameEn: 'SUVs' },
      { id: 'cars_trucks', nameAr: 'شاحنات', nameEn: 'Trucks' },
      { id: 'cars_motorcycles', nameAr: 'دراجات نارية', nameEn: 'Motorcycles' },
      { id: 'cars_parts', nameAr: 'قطع غيار', nameEn: 'Spare Parts' },
    ],
  },
  {
    id: 'real_estate',
    nameAr: 'عقارات',
    nameEn: 'Real Estate',
    icon: 'home',
    order: 2,
    subcategories: [
      { id: 're_apartments', nameAr: 'شقق للبيع', nameEn: 'Apartments for Sale' },
      { id: 're_rent', nameAr: 'شقق للإيجار', nameEn: 'Apartments for Rent' },
      { id: 're_villas', nameAr: 'فلل ومنازل', nameEn: 'Villas & Houses' },
      { id: 're_land', nameAr: 'أراضي', nameEn: 'Land' },
      { id: 're_commercial', nameAr: 'عقارات تجارية', nameEn: 'Commercial' },
    ],
  },
  {
    id: 'mobiles',
    nameAr: 'هواتف ذكية',
    nameEn: 'Mobile Phones',
    icon: 'smartphone',
    order: 3,
    subcategories: [
      { id: 'mob_android', nameAr: 'أندرويد', nameEn: 'Android' },
      { id: 'mob_ios', nameAr: 'آيفون', nameEn: 'iPhone' },
      { id: 'mob_accessories', nameAr: 'إكسسوارات', nameEn: 'Accessories' },
    ],
  },
  {
    id: 'electronics',
    nameAr: 'أجهزة وإلكترونيات',
    nameEn: 'Computers & Electronics',
    icon: 'laptop',
    order: 4,
    subcategories: [
      { id: 'elec_laptops', nameAr: 'لابتوب', nameEn: 'Laptops' },
      { id: 'elec_desktops', nameAr: 'كمبيوتر مكتبي', nameEn: 'Desktops' },
      { id: 'elec_tablets', nameAr: 'أجهزة لوحية', nameEn: 'Tablets' },
      { id: 'elec_tvs', nameAr: 'تلفزيونات', nameEn: 'TVs' },
      { id: 'elec_other', nameAr: 'إلكترونيات أخرى', nameEn: 'Other Electronics' },
    ],
  },
  {
    id: 'furniture',
    nameAr: 'أثاث ومنزليات',
    nameEn: 'Furniture & Home',
    icon: 'chair',
    order: 5,
    subcategories: [
      { id: 'furn_bedroom', nameAr: 'غرف نوم', nameEn: 'Bedroom' },
      { id: 'furn_living', nameAr: 'صالونات', nameEn: 'Living Room' },
      { id: 'furn_kitchen', nameAr: 'أجهزة مطبخ', nameEn: 'Kitchen Appliances' },
      { id: 'furn_decor', nameAr: 'ديكور', nameEn: 'Decor' },
    ],
  },
  {
    id: 'fashion',
    nameAr: 'ملابس وإكسسوارات',
    nameEn: 'Fashion & Accessories',
    icon: 'checkroom',
    order: 6,
    subcategories: [
      { id: 'fash_men', nameAr: 'ملابس رجالية', nameEn: "Men's Clothing" },
      { id: 'fash_women', nameAr: 'ملابس نسائية', nameEn: "Women's Clothing" },
      { id: 'fash_kids', nameAr: 'ملابس أطفال', nameEn: "Children's Clothing" },
      { id: 'fash_bags', nameAr: 'حقائب', nameEn: 'Bags' },
      { id: 'fash_jewelry', nameAr: 'مجوهرات وساعات', nameEn: 'Jewelry & Watches' },
    ],
  },
  {
    id: 'jobs',
    nameAr: 'وظائف',
    nameEn: 'Jobs',
    icon: 'work',
    order: 7,
    subcategories: [
      { id: 'jobs_it', nameAr: 'تقنية المعلومات', nameEn: 'IT & Technology' },
      { id: 'jobs_sales', nameAr: 'مبيعات وتسويق', nameEn: 'Sales & Marketing' },
      { id: 'jobs_education', nameAr: 'تعليم وتدريس', nameEn: 'Education' },
      { id: 'jobs_medical', nameAr: 'طب وصحة', nameEn: 'Medical & Health' },
      { id: 'jobs_other', nameAr: 'وظائف أخرى', nameEn: 'Other Jobs' },
    ],
  },
  {
    id: 'services',
    nameAr: 'خدمات',
    nameEn: 'Services',
    icon: 'build',
    order: 8,
    subcategories: [
      { id: 'svc_maintenance', nameAr: 'صيانة وإصلاح', nameEn: 'Maintenance & Repair' },
      { id: 'svc_cleaning', nameAr: 'تنظيف', nameEn: 'Cleaning' },
      { id: 'svc_transport', nameAr: 'نقل وشحن', nameEn: 'Transport & Shipping' },
      { id: 'svc_education', nameAr: 'دروس خصوصية', nameEn: 'Tutoring' },
      { id: 'svc_other', nameAr: 'خدمات أخرى', nameEn: 'Other Services' },
    ],
  },
  {
    id: 'animals',
    nameAr: 'حيوانات وطيور',
    nameEn: 'Animals & Pets',
    icon: 'pets',
    order: 9,
    subcategories: [
      { id: 'ani_birds', nameAr: 'طيور', nameEn: 'Birds' },
      { id: 'ani_livestock', nameAr: 'مواشي', nameEn: 'Livestock' },
      { id: 'ani_pets', nameAr: 'حيوانات أليفة', nameEn: 'Pets' },
    ],
  },
  {
    id: 'other',
    nameAr: 'منتجات أخرى',
    nameEn: 'Other Products',
    icon: 'category',
    order: 10,
    subcategories: [
      { id: 'other_sports', nameAr: 'رياضة وترفيه', nameEn: 'Sports & Leisure' },
      { id: 'other_books', nameAr: 'كتب وقرطاسية', nameEn: 'Books & Stationery' },
      { id: 'other_misc', nameAr: 'متفرقات', nameEn: 'Miscellaneous' },
    ],
  },
];

/** Locations within Taiz Governorate */
const LOCATIONS = [
  { id: 'taiz_city', nameAr: 'مدينة تعز', nameEn: 'Taiz City', parentId: null, type: 'city' },
  { id: 'taiz_city_jamal', nameAr: 'جمال', nameEn: 'Jamal', parentId: 'taiz_city', type: 'district' },
  { id: 'taiz_city_hawban', nameAr: 'حوبان', nameEn: 'Hawban', parentId: 'taiz_city', type: 'district' },
  { id: 'taiz_city_salateen', nameAr: 'السلاطين', nameEn: 'Al-Salateen', parentId: 'taiz_city', type: 'district' },
  { id: 'taiz_city_gamal', nameAr: 'القاهرة', nameEn: 'Al-Qahira', parentId: 'taiz_city', type: 'district' },
  { id: 'taiz_city_dhabab', nameAr: 'ذباب', nameEn: 'Dhabab', parentId: 'taiz_city', type: 'district' },
  { id: 'taiz_city_sheraton', nameAr: 'شيراتون', nameEn: 'Sheraton Area', parentId: 'taiz_city', type: 'district' },
  { id: 'taiz_turba', nameAr: 'التربة', nameEn: 'Al-Turba', parentId: null, type: 'city' },
  { id: 'taiz_mocha', nameAr: 'المخا', nameEn: 'Mocha', parentId: null, type: 'city' },
  { id: 'taiz_samaa', nameAr: 'الصلو', nameEn: 'Al-Salu', parentId: null, type: 'city' },
];

// ---------------------------------------------------------------------------
// Seed Functions
// ---------------------------------------------------------------------------

async function seedCategories() {
  console.log('Seeding categories...');
  const batch = db.batch();
  let count = 0;

  for (const cat of CATEGORIES) {
    const catRef = db.collection('categories').doc(cat.id);
    batch.set(catRef, {
      nameAr: cat.nameAr,
      nameEn: cat.nameEn,
      icon: cat.icon,
      order: cat.order,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    });
    count++;

    for (const sub of cat.subcategories) {
      const subRef = db.collection('categories').doc(cat.id)
        .collection('subcategories').doc(sub.id);
      batch.set(subRef, {
        nameAr: sub.nameAr,
        nameEn: sub.nameEn,
        parentId: cat.id,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      });
      count++;
    }
  }

  await batch.commit();
  console.log(`  Created ${count} category/subcategory documents.`);
}

async function seedLocations() {
  console.log('Seeding locations...');
  const batch = db.batch();

  for (const loc of LOCATIONS) {
    const ref = db.collection('locations').doc(loc.id);
    batch.set(ref, {
      nameAr: loc.nameAr,
      nameEn: loc.nameEn,
      parentId: loc.parentId,
      type: loc.type,
      governorate: 'taiz',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    });
  }

  await batch.commit();
  console.log(`  Created ${LOCATIONS.length} location documents.`);
}

async function seedPlatformConfig() {
  console.log('Seeding platform config...');
  await db.collection('config').doc('platform').set({
    appName: 'Souq Taiz',
    appNameAr: 'سوق تعز',
    taglineAr: 'سوقك المحلي.. كل شيء أقرب إليك',
    supportedCurrencies: ['YER'],
    defaultCurrency: 'YER',
    maxImagesPerListing: 8,
    maxImageSizeMB: 5,
    defaultListingDurationDays: 90,
    contactEmail: 'support@souqtaiz.com',
    whatsappSupport: '+967000000000',
    version: '1.0.0',
    createdAt: now,
    updatedAt: now,
  });
  console.log('  Platform config document created.');
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

(async () => {
  console.log(`\nSeeding Firestore for project: ${projectId}\n`);

  try {
    await seedCategories();
    await seedLocations();
    await seedPlatformConfig();

    console.log('\nSeed complete! You can now:');
    console.log('  1. Open Firebase Console to verify documents');
    console.log('  2. Run the app: flutter run -d chrome');
    console.log('  3. Create an admin user manually in Authentication,');
    console.log('     then set their role in Firestore: users/{uid}.role = "admin"');
  } catch (err) {
    console.error('\nSeed failed:', err.message);
    process.exit(1);
  }
})();
