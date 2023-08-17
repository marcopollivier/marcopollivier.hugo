+++
authors = ["Marco Ollivier"]
title = "Versionando seu Banco de Dados com Liquibase"
date = "2018-01-27"
description = "Versionando seu Banco de Dados com Liquibase"
tags = [
    "liquibase",
    "databse",
    "source control",
    "springboot"
]
categories = [
    "sre"
]
series = ["Liquibase: versione seu BD"]
+++

Definitivamente o Liquibase não é uma novidade, mas sempre que ele torna minha vida mais fácil com a criação da estrutura dos meus bancos de dados relacionais — especialmente no ambiente de desenvolvimento — , fico com vontade de falar sobre ele para todo mundo. Então não preciso dizer que já faz um tempo considerável que me devo escrever sobre o assunto.

<!--more-->

![liquibase](https://miro.medium.com/v2/format:webp/1*SVQG8pR69GNPquRfJiazZw.jpeg)

## O que é o Liquibase?

Provavelmente você já esteve em um cenário onde era necessário criar uma base de dados nova para preparar um ambiente e quando foi ver era preciso executar diversos scripts SQL com uma quantidade enorme de linhas, ou até mesmo criar mais de uma base de dados ao mesmo tempo. Isso pode se tornar uma tarefa muito cansativa. Existe a possibilidade de esquecer de executar aquele script que fica lá no meio de outros muitos. Definitivamente isso é bem chato. E em um cenário mais crítico: changes em produção? Se esse trabalho não é feito por um DBA, provavelmente será você o responsável por executar essas ação e isso pode ser bem arriscado. Isso sem falar na eventual necessidade de rollback.

Vamos deixar os problemas tradicionais relativos a changes na base de lado por um minuto e começar a pensar simplesmente na possibilidade de versionar os scripts de banco de uma forma parecida como fazemos com o código da aplicação. Os scripts também passariam a ter uma sequencia de execução definida de fato. De quebra ainda seria mais fácil fazer rastreabilidade das alterações.

O Liquibase veio para solucionar todos esses problemas. Com ele será possível versionar as alterações do banco, poderemos fazer rollbacks com muito mais facilidade e ainda teremos uma rastreabilidade do que foi executado e quando. Ah. Também passaremos a garantia de que não importa quantas vezes o script seja executado, nada quebrará. Como? Pela versão ué. Se ele já executou uma versão, não executará outra vez aquela mesma versão.

O Liquibase não é a única solução do tipo no mercado. Existe também outras ferramentas como o Flyway, por exemplo. Porém, como estou mais acostumado com o primeiro, nada mais justo que começar por ele.

Então vamos ao que interessa…

## O básico antes de usar

O Liquibase dá suporte a diversas bases de dados. A lista abaixo são os principais DBs suportados.

![Imagem retirada da página do Liquibase <http://www.liquibase.org/databases.html>
](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*7VqRF2BdIlo5uKSTmTqVOg.png)

Para criar a estrutura das suas tabelas você pode fazer de quatro formas: XML, YAML, JSON e SQL. Abaixo estão alguns exemplos que eu peguei do próprio site do Liquibase.

## [SQL](https://docs.liquibase.com/concepts/changelogs/sql-format.html)

```sql
--liquibase formatted sql
--changeset nvoxland:1
create table test1 (
    id int primary key,
    name varchar(255)
);
--rollback drop table test1;
--changeset nvoxland:2
insert into test1 (id, name) values (1, ‘name 1′);
insert into test1 (id, name) values (2, ‘name 2′);
--changeset nvoxland:3 dbms:oracle
create sequence seq_test;
```

## [XML](http://www.liquibase.org/documentation/xml_format.html)

```xml
<?xml version="1.0" encoding="UTF-8"?>

<databaseChangeLog
        xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:ext="http://www.liquibase.org/xml/ns/dbchangelog-ext"
        xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.0.xsd
        http://www.liquibase.org/xml/ns/dbchangelog-ext http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-ext.xsd">

    <preConditions>
        <runningAs username="liquibase"/>
    </preConditions>

    <changeSet id="1" author="nvoxland">
        <createTable tableName="person">
            <column name="id" type="int" autoIncrement="true">
                <constraints primaryKey="true" nullable="false"/>
            </column>
            <column name="firstname" type="varchar(50)"/>
            <column name="lastname" type="varchar(50)">
                <constraints nullable="false"/>
            </column>
            <column name="state" type="char(2)"/>
        </createTable>
    </changeSet>

    <changeSet id="2" author="nvoxland">
        <addColumn tableName="person">
            <column name="username" type="varchar(8)"/>
        </addColumn>
    </changeSet>
    <changeSet id="3" author="nvoxland">
        <addLookupTable
            existingTableName="person" existingColumnName="state"
            newTableName="state" newColumnName="id" newColumnDataType="char(2)"/>
    </changeSet>

</databaseChangeLog>
```

## [Yaml](https://docs.liquibase.com/concepts/changelogs/yaml-format.html)

```yml
databaseChangeLog:
  - preConditions:
    - runningAs:
        username: liquibase

  - changeSet:
      id: 1
      author: nvoxland
      changes:
        - createTable:
            tableName: person
            columns:
              - column:
                  name: id
                  type: int
                  autoIncrement: true
                  constraints:
                    primaryKey: true
                    nullable: false
              - column:
                  name: firstname
                  type: varchar(50)
              - column:
                  name: lastname
                  type: varchar(50)
                  constraints:
                    nullable: false
              - column:
                  name: state
                  type: char(2)

  - changeSet:
      id: 2
      author: nvoxland
      changes:
        - addColumn:
            tableName: person
            columns:
              - column:
                  name: username
                  type: varchar(8)

  - changeSet:
      id: 3
      author: nvoxland
      changes:
        - addLookupTable:
            existingTableName: person
            existingColumnName:state
            newTableName: state
            newColumnName: id
            newColumnDataType: char(2)
```

## [JSON](http://www.liquibase.org/documentation/json_format.html)

```json
{
    "databaseChangeLog": [
        {
            "preConditions": [
                {
                    "runningAs": {
                        "username": "liquibase"
                    }
                }
            ]
        },

        {
            "changeSet": {
                "id": "1",
                "author": "nvoxland",
                "changes": [
                    {
                        "createTable": {
                            "tableName": "person",
                            "columns": [
                                {
                                    "column": {
                                        "name": "id",
                                        "type": "int",
                                        "autoIncrement": true,
                                        "constraints": {
                                            "primaryKey": true,
                                            "nullable": false
                                        },
                                    }
                                },
                                {
                                    "column": {
                                        "name": "firstname",
                                        "type": "varchar(50)"
                                    }
                                },
                                {
                                    "column": {
                                        "name": "lastname",
                                        "type": "varchar(50)",
                                        "constraints": {
                                            "nullable": false
                                        },
                                    }
                                },
                                {
                                    "column": {
                                        "name": "state",
                                        "type": "char(2)"
                                    }
                                }
                            ]
                        }
                    }
                ]
            }
        },

        {
            "changeSet": {
                "id": "2",
                "author": "nvoxland",
                "changes": [
                    {
                        "addColumn": {
                            "tableName": "person",
                            "columns": [
                                {
                                    "column": {
                                        "name": "username",
                                        "type": "varchar(8)"
                                    }
                                }
                           ]
                        }
                    }
                ]
            }
        },

        {
            "changeSet": {
                "id": "3",
                "author": "nvoxland",
                "changes": [
                    {
                        "addLookupTable": {
                            "existingTableName": "person",
                            "existingColumnName":"state",
                            "newTableName": "state",
                            "newColumnName": "id",
                            "newColumnDataType": "char(2)",
                        }
                    }
                ]
            }
        }
    ]
}
```

Francamente SQL é minha opção favorita. Apesar de já ter utilizado também o formato YAML e achar bem interessante já que não ficamos tão amarrados a eventuais pequenas mudanças no SQL de um DB para outro.

---

## Hands-on

Agora que já entendemos um pouco do básico para a utilização do Liquibase, vamos enfim colocar a mão na massa e fazer uma pequena aplicação. Para isso faremos uma aplicação em **SpringBoot** e **Maven** e utilizaremos o **H2** em memória para persistir os dados.

O modelo que utilizaremos será o seguinte.

![relacionamento](https://miro.medium.com/v2/resize:fit:738/format:webp/1*WbuDfDesH7Cbz6KQi2sDSg.png)

> Não entraremos em muitos detalhes na construção do projeto em si, pois ele não é o foco nesse momento. Mas no final eu postarei o endereço do Github com o projeto completo.

**Vamos começar criando a estrutura básica do projeto**

1. Criar nossa estrutura do projeto no [SPRING INITIALIZR](https://start.spring.io/).

2. Adicionar as dependências necessárias no **pom.xml**

```xml
<dependency>
   <groupId>org.springframework.boot</groupId>
   <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<dependency>
   <groupId>com.h2database</groupId>
   <artifactId>h2</artifactId>
</dependency>
<dependency>
   <groupId>org.liquibase</groupId>
   <artifactId>liquibase-core</artifactId>
</dependency>
```

3. Adicionando as configurações no **application.yml** do SpringBoot

```yml
spring:
  h2.console:
    enabled: true
    path: /h2
  datasource:
    url: jdbc:h2:mem:responsive-br-versionamento-db-liquibase
    username: sa
    password:
    driver-class-name: org.h2.Driver
    initialize: true
  jpa:
    show-sql: true
    properties.hibernate:
      dialect: org.hibernate.dialect.H2Dialect
      naming-strategy: org.springframework.boot.orm.jpa.hibernate.SpringNamingStrategy
    hibernate:
      ddl-auto: validate
    database-platform: org.hibernate.dialect.H2Dialect
```

Com o passo 3 feito, já podemos de fato pensar na nossa estrutura do banco de dados. Para esse exemplo escreveremos nosso próprio SQL e deixaremos o Liquibase responsável por gerenciar essa criação. Vale inclusive notar que o ddl-auto do Hibernate está apenas como validate. Portanto ele não fará nenhum tipo de alteração na base e apenas verificará se está de acordo com o mapeamento feito nas classes de modelos.

4. Criar o changelog e adicionar os SQLs que serão utilizados

Será necessário criar dentro de resource a pastas **db/changelog** e **db/changelog/migrations**

Dentro de **db/changelog** será criado o um arquivo chamado **db.changelog-master.yaml**. Esse será o arquivo onde será indicado quais arquivos serão utilizados pelo Liquibase como base para criação do BD. Para esse exemplo, ele ficará da seguinte forma:

```yml
databaseChangeLog:
  - include:
      file: migrations/001_schema_inicial.sql
      relativeToChangelogFile: true
```

E dentro de **db/changelog/migrations** ficará os arquivos SQL.

```sql
--liquibase formatted sql

--changeset marcopollivier:1
CREATE TABLE IF NOT EXISTS product (
 id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY CONSTRAINT product_pkey PRIMARY KEY ,
 description VARCHAR(255),
 name VARCHAR(255),
 parent_product_id BIGINT CONSTRAINT product_parent_fkey references product
);

CREATE TABLE IF NOT EXISTS image (
 id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY CONSTRAINT image_pkey PRIMARY KEY,
 type VARCHAR(255),
 product_id BIGINT CONSTRAINT product_image_fkey REFERENCES product
);

--rollback ALTER TABLE image DROP CONSTRAINT product_image_fkey;
--rollback ALTER TABLE product DROP CONSTRAINT product_parent_fkey;
--rollback DROP TABLE image;
--rollback DROP TABLE product;
```

Repare que a primeira linha identifica que esse realmente será um arquivo utilizado pelo Liquibase e reforça que o padrão utilizado será o SQL

```sql
--liquibase formatted sql
```

O segundo pondo de atenção é a configuração do changeset. É nessa linha que será informado quem fez e o número da versão dessa change. Essas informações serão armazenadas em tabelas de metadados do Liquibase e esses dados formam uma chave composta de modo que não pode existir dois scripts diferente com a mesma combinação de usuário+versão

```sql
--changeset marcopollivier:1
```

E por ultimo as linhas de rollback. Essa é uma das coisas mais bacanas da ferramenta como um todo. Como eu posso executar um comando da biblioteca do Liquibase e efetuar o rollback de uma determinada versão, será executado exatamente o que está sendo definido nessas linhas.

A estrutura do projeto até o momento está da seguinte forma

![ide](https://miro.medium.com/v2/resize:fit:934/format:webp/1*nVAjyshGg0YEJSe-SgPpkQ.png)

Nesse momento já é possível rodar a aplicação sem que dê erro.

5. Reta final! Agora é criar as classes de modelo e os Repositórios.

Classe imagem

```java
package com.github.responsivebr.versionamentobdliquibase.app.domain.model;

import javax.persistence.*;

@Entity
@Table(name = "image")
public class Image {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }
}
```

Classe Produto

```java
package com.github.responsivebr.versionamentobdliquibase.app.domain.model;


import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "product")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_product_id")
    private Product parentProduct;

    @OneToMany(
            mappedBy = "parentProduct",
            cascade = CascadeType.ALL,
            fetch = FetchType.LAZY)
    private Set<Product> subProducts;

    @OneToMany(
            mappedBy = "product",
            cascade = CascadeType.ALL,
            fetch = FetchType.LAZY)
    private Set<Image> images;

    public Product() {
        subProducts = new HashSet<>();
        images = new HashSet<>();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Product getParentProduct() {
        return parentProduct;
    }

    public void setParentProduct(Product parentProduct) {
        this.parentProduct = parentProduct;
    }

    public Set<Product> getSubProducts() {
        return subProducts;
    }

    public void setSubProducts(Set<Product> subProducts) {
        this.subProducts = subProducts;
    }

    public Set<Image> getImages() {
        return images;
    }

    public void setImages(Set<Image> images) {
        this.images = images;
    }

    //
    public void addSubProduct(Product product) {
        if(product != null) {
            this.subProducts.add(product);
            product.setParentProduct(this);
        }
    }

    public void addImage(Image image) {
        if(image != null) {
            this.images.add(image);
            image.setProduct(this);
        }
    }
}
```

Repositório de Imagem

```java
package com.github.responsivebr.versionamentobdliquibase.app.domain.repository;

import com.github.responsivebr.versionamentobdliquibase.app.domain.model.Image;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ImageRepository extends JpaRepository<Image, Long> {
    
}
```

Repositório de Produto

```java
package com.github.responsivebr.versionamentobdliquibase.app.domain.repository;

import com.github.responsivebr.versionamentobdliquibase.app.domain.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

}
```

E por fim, adicionar a anotação **EntityScan** no na classe da Aplicação

```java
package com.github.responsivebr.versionamentobdliquibase;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.convert.threeten.Jsr310JpaConverters;

@SpringBootApplication
@EntityScan(basePackageClasses = {Application.class, Jsr310JpaConverters.class})
public class Application {

   public static void main(String[] args) {
      SpringApplication.run(Application.class, args);
   }

}
```

E pronto. A estrutura do banco está sendo criada pelo Liquibase e a aplicação está devidamente mapeada.

Agora o passo final é criar um teste básico para confirmar que está tudo de acordo.

```java
package com.github.responsivebr.versionamentobdliquibase;

import com.github.responsivebr.versionamentobdliquibase.app.domain.model.Image;
import com.github.responsivebr.versionamentobdliquibase.app.domain.model.Product;
import com.github.responsivebr.versionamentobdliquibase.app.domain.repository.ProductRepository;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest
public class ValidationTest {

    @Autowired
    ProductRepository productRepository;


    @Test
    public void testApplicationPersistence() {

        Product product = buildProduct();

        Product savedProduct = productRepository.save(product);


        Assert.assertNotNull(savedProduct.getId());

        Assert.assertNotNull(savedProduct.getImages().stream().findFirst().get().getId());

        Assert.assertNotNull(savedProduct.getSubProducts().stream().findFirst().get().getId());

        Assert.assertEquals("Default image", savedProduct.getImages().stream().findFirst().get().getType());

        Assert.assertEquals("Child Product", savedProduct.getSubProducts().stream().findFirst().get().getName());


    }

    private Image buildImage() {
        Image im = new Image();
        im.setType("Default image");

        return im;
    }

    private Product buildChildProduct() {
        Product parent = new Product();
        parent.setName("Child Product");
        parent.setDescription("This is a child product");
        return parent;
    }

    private Product buildProduct() {
        Product parent = new Product();
        parent.setName("Parent Product");
        parent.setDescription("This is a parent product");

        parent.addImage(buildImage());
        parent.addSubProduct(buildChildProduct());

        return parent;
    }
}
```

Executando o teste, se torna possível testar e comprovar que tudo foi criado corretamente e que as informações estão sendo persistidas sem maiores problemas.

---

## Conclusão

Uma das boas práticas que já está no nosso cotidiano do desenvolvimento é o controle de versão de código. Hoje vimos que é possível ter esse mesmo controle nas alterações da nossa base de dados utilizando uma ferramenta como o Liquibase. Dessa forma fica mais fácil controlarmos qualquer tipo de alteração da nossa base de dados, nos proporcionando um pouco mais de segurança para realizar esse tipo de atividade.

---

[Repositorio Github](https://github.com/marcopollivier/versionamento-db-liquibase)
[Liquibase](https://www.liquibase.org/)

---

No próximo post vamos aprofundar um pouco mais no Liquibase e ver algumas funcionalidades que ele nos proporciona.

Espero que este post tenha sido verdadeiramente útil. Qualquer dúvida ou sugestão, por favor não hesite em escrever nos comentários.

Até a próxima.
