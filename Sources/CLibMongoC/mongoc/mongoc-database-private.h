/*
 * Copyright 2013 MongoDB, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "CLibMongoC_mongoc-prelude.h"

#ifndef MONGOC_DATABASE_PRIVATE_H
#define MONGOC_DATABASE_PRIVATE_H

#include <CLibMongoC_bson.h>

#include "CLibMongoC_mongoc-client.h"
#include "CLibMongoC_mongoc-read-prefs.h"
#include "CLibMongoC_mongoc-read-concern.h"
#include "CLibMongoC_mongoc-write-concern.h"

BSON_BEGIN_DECLS


struct _mongoc_database_t {
   mongoc_client_t *client;
   char *name;
   mongoc_read_prefs_t *read_prefs;
   mongoc_read_concern_t *read_concern;
   mongoc_write_concern_t *write_concern;
   int64_t timeout_ms;
};


mongoc_database_t *
_mongoc_database_new (mongoc_client_t *client,
                      const char *name,
                      const mongoc_read_prefs_t *read_prefs,
                      const mongoc_read_concern_t *read_concern,
                      const mongoc_write_concern_t *write_concern,
                      int64_t timeout_ms);

BSON_END_DECLS


#endif /* MONGOC_DATABASE_PRIVATE_H */
