DROP DATABASE IF EXISTS hydradb;
CREATE DATABASE hydradb;

USE hydradb;

/* Project network and scenearios */

CREATE TABLE tProject (
    project_id          INT           NOT NULL PRIMARY KEY AUTO_INCREMENT,
    project_name        VARCHAR(45)   NOT NULL,
    project_description VARCHAR(1000),
    status              VARCHAR(1) default 'A' NOT NULL,
    cr_date  TIMESTAMP default localtimestamp,
    created_by          INT
);

CREATE TABLE tNetwork (
    network_id          INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    network_name        VARCHAR(45)  NOT NULL,
    network_description VARCHAR(1000),
    project_id          INT          NOT NULL,
    status              VARCHAR(1) default 'A' NOT NULL,
    cr_date  TIMESTAMP default localtimestamp,
    projection          VARCHAR(1000),
    FOREIGN KEY (project_id) REFERENCES tProject(project_id)
);

CREATE TABLE tNode (
    node_id          INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    network_id       INT         NOT NULL,
    node_description VARCHAR(45),
    node_name        VARCHAR(45) NOT NULL,
    status           VARCHAR(1) default 'A' NOT NULL,
    node_x           DOUBLE,
    node_y           DOUBLE,
    node_layout      VARCHAR(1000),
    cr_date  TIMESTAMP default localtimestamp,
    FOREIGN KEY (network_id) REFERENCES tNetwork(network_id)
);

CREATE TABLE tLink (
    link_id         INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    network_id      INT          NOT NULL,
    status          VARCHAR(1) default 'A' NOT NULL,
    node_1_id       INT          NOT NULL,
    node_2_id       INT          NOT NULL,
    link_name       VARCHAR(45),
    link_layout     VARCHAR(1000),
    cr_date  TIMESTAMP default localtimestamp,
    FOREIGN KEY (network_id) REFERENCES tNetwork(network_id),
    FOREIGN KEY (node_1_id) REFERENCES tNode(node_id),
    FOREIGN KEY (node_2_id) REFERENCES tNode(node_id)
);

CREATE TABLE tScenario (
    scenario_id          INT           NOT NULL PRIMARY KEY AUTO_INCREMENT,
    scenario_name        VARCHAR(45)   NOT NULL,
    scenario_description VARCHAR(1000),
    status               VARCHAR(1) default 'A' NOT NULL,
    network_id           INT,
    cr_date  TIMESTAMP default localtimestamp,
    FOREIGN KEY (network_id) REFERENCES tNetwork(network_id)
);

/* Attributes */

CREATE TABLE tAttr (
    attr_id    INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    attr_name  VARCHAR(45) NOT NULL,
    attr_dimen VARCHAR(45),
    cr_date  TIMESTAMP default localtimestamp
);

CREATE TABLE tResourceTemplateGroup (
    group_id   INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    group_name VARCHAR(45) NOT NULL
);

CREATE TABLE tResourceTemplate(
    template_id   INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    template_name VARCHAR(45) NOT NULL,
    group_id INT,
    FOREIGN KEY (group_id) REFERENCES tResourceTemplateGroup(group_id)
);

CREATE TABLE tResourceTemplateItem (
    attr_id     INT NOT NULL,
    template_id INT NOT NULL,
    PRIMARY KEY (attr_id, template_id),
    FOREIGN KEY (attr_id) REFERENCES tAttr(attr_id),
    FOREIGN KEY (template_id) REFERENCES tResourceTemplate(template_id)
);

CREATE TABLE tAttrMap (
    attr_id_a INT NOT NULL,
    attr_id_b INT NOT NULL,
    PRIMARY KEY (attr_id_a, attr_id_b),
    FOREIGN KEY (attr_id_a) REFERENCES tAttr(attr_id),
    FOREIGN KEY (attr_id_b) REFERENCES tAttr(attr_id)
);

CREATE TABLE tResourceAttr (
    resource_attr_id INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    attr_id          INT         NOT NULL,
    ref_key          VARCHAR(45) NOT NULL,
    ref_id           INT         NOT NULL,
    attr_is_var      VARCHAR(1)  NOT NULL default 'N',
    FOREIGN KEY (attr_id) REFERENCES tAttr(attr_id)
);

/* Constraints */

CREATE TABLE tConstraint (
    constraint_id INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    scenario_id   INT         NOT NULL,
    group_id      INT,
    constant      DOUBLE      NOT NULL,
    op            VARCHAR(10) NOT NULL,
    FOREIGN KEY (scenario_id) REFERENCES tScenario(scenario_id)
);

CREATE TABLE tConstraintItem (
    item_id          INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    constraint_id    INT NOT NULL,
    resource_attr_id INT NOT NULL,
    FOREIGN KEY (constraint_id) REFERENCES tConstraint(constraint_id),
    FOREIGN KEY (resource_attr_id) REFERENCES tResourceAttr(resource_Attr_id)
);

CREATE TABLE tConstraintGroup (
    group_id      INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    constraint_id INT         NOT NULL,
    ref_key_1     VARCHAR(45) NOT NULL,
    ref_id_1      INT         NOT NULL,
    ref_key_2     VARCHAR(45),
    ref_id_2      INT,
    op            VARCHAR(10),
    FOREIGN KEY (constraint_id) REFERENCES tConstraint(constraint_id)
);

/* Data representation */

CREATE TABLE tDescriptor (
    data_id  INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    desc_val VARCHAR(45) NOT NULL
);

CREATE TABLE tTimeSeries (
    data_id  INT      NOT NULL PRIMARY KEY AUTO_INCREMENT
);

CREATE TABLE tTimeSeriesData(
    data_id  INT         NOT NULL,
    ts_time  DATETIME    NOT NULL,
    ts_value BLOB        NOT NULL,
    PRIMARY KEY (data_id, ts_time),
    FOREIGN KEY (data_id) references tTimeSeries(data_id)
);

CREATE TABLE tEqTimeSeries (
    data_id       INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    start_time    DATETIME    NOT NULL,
    frequency     DOUBLE      NOT NULL,
    arr_data      BLOB        NOT NULL
);

CREATE TABLE tScalar (
    data_id     INT    NOT NULL PRIMARY KEY AUTO_INCREMENT,
    param_value DOUBLE NOT NULL
);

CREATE TABLE tArray (
    data_id        INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    arr_data       BLOB        NOT NULL
);

CREATE TABLE tScenarioData (
    dataset_id  INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    data_id     INT         NOT NULL,
    data_type   VARCHAR(45) NOT NULL,
    data_units  VARCHAR(45) NOT NULL,
    data_name   VARCHAR(45) NOT NULL,
    data_dimen  VARCHAR(45) NOT NULL,
    cr_date  TIMESTAMP default localtimestamp,
    constraint chk_type check (data_type in ('descriptor', 'timeseries',
    'eqtimeseries', 'scalar', 'array'))
);

CREATE TABLE tDataAttr (
    d_attr_id   INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    dataset_id  INT         NOT NULL,
    d_attr_name VARCHAR(45) NOT NULL,
    d_attr_val  DOUBLE      NOT NULL,
    FOREIGN KEY (dataset_id) REFERENCES tScenarioData(dataset_id)
);

CREATE TABLE tResourceScenario (
    dataset_id          INT NOT NULL,
    scenario_id      INT NOT NULL,
    resource_attr_id INT NOT NULL,
    PRIMARY KEY (resource_attr_id, scenario_id),
    FOREIGN KEY (scenario_id) REFERENCES tScenario(scenario_id),
    FOREIGN KEY (dataset_id) REFERENCES tScenarioData(dataset_id),
    FOREIGN KEY (resource_attr_id) REFERENCES tResourceAttr(resource_attr_id)
);

/* ========================================================================= */
/* User permission management                                                */

CREATE TABLE tUser (
    user_id  INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    username varchar(45) NOT NULL,
    password varchar(1000) NOT NULL,
    cr_date  TIMESTAMP default localtimestamp
);

CREATE TABLE tRole (
    role_id   INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(45) NOT NULL,
    cr_date  TIMESTAMP default localtimestamp
);

CREATE TABLE tPerm (
    perm_id   INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    perm_name VARCHAR(45) NOT NULL,
    cr_date  TIMESTAMP default localtimestamp
);

CREATE TABLE tRoleUser (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    cr_date  TIMESTAMP default localtimestamp,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES tUser(user_id),
    FOREIGN KEY (role_id) REFERENCES tRole(role_id)
);

CREATE TABLE tRolePerm (
    perm_id INT NOT NULL,
    role_id INT NOT NULL,
    cr_date  TIMESTAMP default localtimestamp,
    PRIMARY KEY (perm_id, role_id),
    FOREIGN KEY (perm_id) REFERENCES tPerm(perm_id),
    FOREIGN KEY (role_id) REFERENCES tRole(role_id)
);

CREATE TABLE tProjectOwner (
    user_id INT NOT NULL,
    project_id INT NOT NULL,
    cr_date  TIMESTAMP default localtimestamp,
    PRIMARY KEY (user_id, project_id),
    FOREIGN KEY (user_id) REFERENCES tUser(user_id),
    FOREIGN KEY (project_id) REFERENCES tProject(project_id)
);

CREATE TABLE tDatasetOwner (
    user_id INT NOT NULL,
    dataset_id INT NOT NULL,
    cr_date  TIMESTAMP default localtimestamp,
    PRIMARY KEY (user_id, dataset_id),
    FOREIGN KEY (user_id) REFERENCES tUser(user_id),
    FOREIGN KEY (dataset_id) REFERENCES tScenarioData(dataset_id)
);
