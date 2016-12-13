#!/usr/bin/env python

import geopy.geocoders
import os.path
import pytz
import sqlite3
import time

db = sqlite3.connect('cvs.sqlite')

try:
  db.execute('ALTER TABLE store ADD COLUMN timezone TEXT NULL')
except sqlite3.OperationalError:
  print('It seems timezone column already exists')

geolocator = geopy.geocoders.GoogleV3()

store_query = """
  SELECT id, latitude, longitude
  FROM store
  WHERE timezone IS NULL
"""

try:
  while True:
    stores = db.execute(store_query).fetchall()
    if len(stores) == 0:
      break
    for id, latitude, longitude in stores:
      try:
        time.sleep(0.2)
        timezone = geolocator.timezone((latitude, longitude))
      except Exception as e:
        print('Geocoder returned error: {}'.format(e))
        break
      if timezone is not None:
        print('Found timezone for store {}: {}'.format(id, timezone))
        db.execute('UPDATE store SET timezone = ? WHERE id = ?',
                   (str(timezone), id))
      else:
        print('Failed to get timezone for store {}'.format(id))
except KeyboardInterrupt:
  pass

db.commit()
