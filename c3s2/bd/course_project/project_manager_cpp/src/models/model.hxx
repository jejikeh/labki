#pragma once

#include <pqxx/pqxx>
#include <string>

class ModelEntity
{
public:
    std::string id;

    virtual std::string table_name() const = 0;
    virtual std::string to_insert_sql() const = 0;
    virtual void from_pqxx_row(const pqxx::row& res) = 0;
};